import numpy as np
import matplotlib.pyplot as plt
from scipy.integrate import solve_ivp

# Constants
beta = 1.5e9
V = 7.3e-5
k_nozzle = 2.3e-9
Pmax = 517000
Lu = 5e6
Ld = 5e7
Ru = 1e10
Rd = 1.94e11

def u_t(t):
    if t < 1:
        return 0.0
    elif t < 2.5:
        return (t - 1) / 1.5   # ramp up
    elif t < 7:
        return 1.0             # ON
    elif t < 8.5:
        return 1.0 - (t - 7) / 1.5  # ramp down
    else:
        return 0.0

def system_dynamics(t, y):
    P_up, Q_up, Q_down = y
    
    u = u_t(t)
    
    # Pump pressure
    P_pump = Pmax * u
    
    # Prevent negative pressure in sqrt
    P_safe = max(P_up, 0)
    Q_nozzle = k_nozzle * np.sqrt(P_safe)
    
    # Pressure dynamics
    dp_dt = (beta / V) * (Q_up - Q_down - Q_nozzle)
    
    # Flow dynamics
    dq_up_dt = (1 / Lu) * (P_pump - P_up - Ru * Q_up)
    dq_down_dt = (1 / Ld) * (P_up - Rd * Q_down)
    
    return [dp_dt, dq_up_dt, dq_down_dt]


# Time span 0 to 10 seconds
t_span = (0, 10)
t_eval = np.linspace(0, 10, 2000)
y0 = [0.0, 0.0, 0.0]

# Solve using Radau method for stiff systems
sol = solve_ivp(system_dynamics, t_span, y0, t_eval=t_eval, method='Radau')

# Extract results
P_up_vals = sol.y[0]
Q_up_vals = sol.y[1]
Q_down_vals = sol.y[2]
Q_nozzle_vals = k_nozzle * np.sqrt(np.maximum(P_up_vals, 0))

# Plotting
fig, ax1 = plt.subplots(figsize=(10, 6))

ax1.plot(sol.t, P_up_vals, color='red', label='Pressure (P_up)')
ax1.set_ylabel('Pressure (Pa)', color='red')
ax1.tick_params(axis='y', labelcolor='red')
ax1.grid(True, alpha=0.3)

ax2 = ax1.twinx()
ax2.plot(sol.t, Q_up_vals, label='Q_up', color='blue')
ax2.plot(sol.t, Q_down_vals, label='Q_down', color='orange', linestyle='--')
ax2.plot(sol.t, Q_nozzle_vals, label='Q_nozzle', color='green')
ax2.set_ylabel('Flow Rate (m³/s)', color='blue')
ax2.tick_params(axis='y', labelcolor='blue')

plt.title('Pressure and Flow Rate Simulation With Transient Flow')
fig.tight_layout()
ax1.legend(loc='upper left')
ax2.legend(loc='upper right')
plt.show()
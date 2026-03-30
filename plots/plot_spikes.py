import numpy as np
import matplotlib.pyplot as plt
from scipy.integrate import solve_ivp

# Constants
max_pressure = 517000
k_pressure = 2.05e13
inertia_up = 2e-7
inertia_down = 2e-8
resistance_up = 1e10
resistance_down = 1.94e11
k_nozzle = 2.3e-9


def u_t(t):
    """
    Pump level u(t) that goes from 0-1 at 1-2.5s and from 1-0 at 7-8.5s.
    """
    if t < 1:
        return 0.0
    elif t < 2.5:
        return (t - 1) / 1.5
    elif t < 7:
        return 1.0
    elif t < 8.5:
        return 1.0 - (t - 7) / 1.5
    else:
        return 0.0

def system_dynamics(t, y):
    """
    Calculates dP/dt, dQup/dt, and dQdown/dt for the system.
    """
    pressure, flow_up, flow_down = y
    u = u_t(t)
    
    # Flow nozzle: k-nozzle * sqrt(P)
    flow_nozzle = k_nozzle * np.sqrt(max(pressure, 0))
    
    # Pressure: dP/dt = k-pressure * (flow-up - flow-down - flow-nozzle)
    dpdt = k_pressure * (flow_up - flow_down - flow_nozzle)
    
    # Flow up: dQ-up/dt = inertia-up * (max-pressure * pump-level - P - resistance-up * Q-up)
    dqupdt = inertia_up * (max_pressure * u - pressure - resistance_up * flow_up)

    # Flow down: dQ-down/dt = inertia-down * (P - resistance-down * Q-down)
    dqdowndt = inertia_down * (pressure - resistance_down * flow_down)
    
    return [dpdt, dqupdt, dqdowndt]


# Time setup
t_span = (0, 10)
t_eval = np.linspace(0, 10, 2000)
y0 = [0.0, 0.0, 0.0]  # Initial conditions: P = 0, Q-up = 0, Q-down = 0

# Solve using Radau method for stiff systems
sol = solve_ivp(system_dynamics, t_span, y0, t_eval=t_eval, method='Radau')

# Extract results
P_vals = sol.y[0]
Qup_vals = sol.y[1]
Qdown_vals = sol.y[2]
Qnozzle_vals = k_nozzle * np.sqrt(np.maximum(P_vals, 0))

# Plotting
fig, ax1 = plt.subplots(figsize=(10, 6))

# Primary Y-axis: Pressure
ax1.set_xlabel('Time (t)')
ax1.set_ylabel('Pressure (Pa)', color='red')
ax1.plot(sol.t, P_vals, color='red', label='Pressure (P)')
ax1.tick_params(axis='y', labelcolor='red')
ax1.grid(True, alpha=0.3)

# Secondary Y-axis: Flow Rates
ax2 = ax1.twinx()
ax2.set_ylabel('Flow Rate (m³/s)', color='blue')
ax2.plot(sol.t, Qup_vals, label='Q_up', color='blue')
ax2.plot(sol.t, Qdown_vals, label='Q_down', color='orange', linestyle='--')
ax2.plot(sol.t, Qnozzle_vals, label='Q_nozzle', color='green')
ax2.tick_params(axis='y', labelcolor='blue')

# Plot title and legend
plt.title('Pressure and Flow Rate Simulation With Transient Flow')
ax1.legend(loc='upper left')
ax2.legend(loc='upper right')
fig.tight_layout()
plt.show()

import numpy as np
import matplotlib.pyplot as plt
from scipy.integrate import odeint

# Constants
Pmax   = 75
k_time = 5
k_nozzle = 0.018475
Ru     = 288.461539

def u_t(t):
    """Control signal u(t) with specified ramps: 1-2.5s and 7-8.5s."""
    if t < 1:
        return 0.0
    elif 1 <= t < 2.5:
        return (t - 1) / 1.5
    elif 2.5 <= t < 7:
        return 1.0
    elif 7 <= t < 8.5:
        return 1.0 - (t - 7) / 1.5
    else:
        return 0.0

def system_dynamics(y, t):
    P, Qup, Qnozzle = y
    u = u_t(t)
    
    # Pressure dP/dt
    dpdt = k_time * u * (Pmax - P) - k_time * (1 - u) * P
    
    # Flow Up dQup/dt
    dqupdt = k_time * u * (P/Ru - Qup) - k_time * (1 - u) * Qup
    
    # Flow Nozzle dQnozzle/dt (max(P,0) prevents sqrt errors)
    dqnozzledt = k_time * u * (k_nozzle * np.sqrt(max(P, 0)) - Qnozzle) - k_time * (1 - u) * Qnozzle
    
    return [dpdt, dqupdt, dqnozzledt]

# Time setup
t = np.linspace(0, 10, 1000)
y0 = [0.0, 0.0, 0.0]  # Initial conditions: P=0, Qup=0, Qnozzle=0

# Solve the ODEs
solution = odeint(system_dynamics, y0, t)
P_vals = solution[:, 0]
Qup_vals = solution[:, 1]
Qnoz_vals = solution[:, 2]
Qdown_vals = Qup_vals - Qnoz_vals

# Plotting
fig, ax1 = plt.subplots(figsize=(10, 6))

# Primary Y-axis: Pressure
ax1.set_xlabel('Time (t)')
ax1.set_ylabel('Pressure (P)', color='tab:red')
ax1.plot(t, P_vals, color='tab:red', linewidth=2, label='Pressure (P)')
ax1.tick_params(axis='y', labelcolor='tab:red')
ax1.grid(True, alpha=0.3)

# Secondary Y-axis: Flow Rates
ax2 = ax1.twinx()
ax2.set_ylabel('Flow Rate (Q)', color='tab:blue')
ax2.plot(t, Qup_vals, color='tab:blue', label='Flow-Up (Qup)')
ax2.plot(t, Qnoz_vals, color='tab:green', label='Flow-Nozzle (Qnoz)')
ax2.plot(t, Qdown_vals, color='tab:orange', linestyle='--', label='Flow-Down (Qdown)')
ax2.tick_params(axis='y', labelcolor='tab:blue')

plt.title('Pressure and Flow Rate With Steady Flow')
ax1.legend(loc='upper left')
ax2.legend(loc='upper right')
fig.tight_layout()
plt.show()
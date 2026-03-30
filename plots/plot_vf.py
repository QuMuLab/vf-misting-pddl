import numpy as np
import matplotlib.pyplot as plt
from scipy.integrate import odeint

# Constants
max_pressure = 75
k_time = 5
resistance_up = 288.4615
k_nozzle = 0.011547


def u_t(t):
    """
    Pump level u(t) that goes from 0-1 at 1-2.5s and from 1-0 at 7-8.5s.
    """
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
    """
    Calculates dP/dt, dQup/dt, and dQnozzle/dt for the system.
    """
    pressure, flow_up, flow_nozzle = y
    u = u_t(t)
    
    # Pressure: dP/dt = k-time * pump-level * (P-max - P) - k-time * (1 - pump-level) * P
    dpdt = k_time * u * (max_pressure - pressure) - k_time * (1 - u) * pressure
    
    # Flow up: dQ-up/dt = k-time * pump-level * (P / R - Q-up) - k-time * (1 - pump-level) * Q-up
    dqupdt = k_time * u * (pressure / resistance_up - flow_up) - k_time * (1 - u) * flow_up
    
    # Flow nozzle: dQ-nozzle/dt = k-time * pump-level * (k-nozzle * sqrt(P) - Q-nozzle)
    dqnozzledt = k_time * u * (k_nozzle * np.sqrt(max(pressure, 0)) - flow_nozzle) - k_time * (1 - u) * flow_nozzle
    
    return [dpdt, dqupdt, dqnozzledt]


# Time setup
t = np.linspace(0, 10, 1000)
y0 = [0.0, 0.0, 0.0]  # Initial conditions: P = 0, Q-up = 0, Q-nozzle = 0

# Solve the ODEs
solution = odeint(system_dynamics, y0, t)
P_vals = solution[:, 0]
Qup_vals = solution[:, 1]
Qnozzle_vals = solution[:, 2]
Qdown_vals = Qup_vals - Qnozzle_vals

# Plotting
fig, ax1 = plt.subplots(figsize=(10, 6))

# Primary Y-axis: Pressure
ax1.set_xlabel('Time (t)')
ax1.set_ylabel('Pressure (psi)', color='tab:red')
ax1.plot(t, P_vals, color='tab:red', linewidth=2, label='Pressure (P)')
ax1.tick_params(axis='y', labelcolor='tab:red')
ax1.grid(True, alpha=0.3)

# Secondary Y-axis: Flow Rates
ax2 = ax1.twinx()
ax2.set_ylabel('Flow Rate (L/min)', color='tab:blue')
ax2.plot(t, Qup_vals, color='tab:blue', label='Flow-Up (Q_up)')
ax2.plot(t, Qnozzle_vals, color='tab:green', label='Flow-Nozzle (Q_nozzle)')
ax2.plot(t, Qdown_vals, color='tab:orange', linestyle='--', label='Flow-Down (Q_down)')
ax2.tick_params(axis='y', labelcolor='tab:blue')

# Plot title and legend
plt.title('Pressure and Flow Rate With Steady Flow')
ax1.legend(loc='upper left')
ax2.legend(loc='upper right')
fig.tight_layout()
plt.show()

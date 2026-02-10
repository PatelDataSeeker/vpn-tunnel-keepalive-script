# VPN Interface Keepalive Monitor

## Overview
This script was built to solve a real production issue in a healthcare integration environment.

A site-to-site VPN tunnel supporting real-time HL7 interfaces was intermittently going idle and dropping. When that happened, interfaces would appear “up” from an application perspective but would silently fail until traffic resumed or someone manually intervened.

To reduce downtime and avoid reactive troubleshooting, I created a lightweight PowerShell-based monitor to generate periodic traffic across the tunnel and log connectivity status.

---

## The Problem
1. A VPN tunnel used by real-time HL7 interfaces would drop due to idle timeouts.
2. When the tunnel dropped, interface traffic stopped without immediate visibility.
3. This caused avoidable interface downtime and operational risk in production.

---

## The Approach
1. Externalized interface definitions (name, IP, port) into a JSON configuration file so changes could be made without touching the script.
2. Built a PowerShell script that:
   - Iterates through configured interface endpoints
   - Sends ICMP traffic to keep the VPN tunnel active
   - Logs connectivity results with timestamps for operational visibility

---

## The Outcome
- Reduced VPN idle-time drops by keeping traffic flowing across the tunnel.
- Improved real-time interface uptime.
- Created a simple audit trail to support troubleshooting and trend analysis.

---

## How It Works
- Reads interface definitions from a JSON config file.
- Pings each configured IP address to validate reachability and generate keepalive traffic.
- Logs success/failure and response time to a centralized log file.
- Skips misconfigured entries safely without failing the entire run.

The script is intentionally simple, dependency-free, and designed for scheduled execution (e.g., Windows Task Scheduler).

---

## Configuration
Interfaces are defined in a JSON file:

```json
{
  "interfaces": [
    {
      "name": "Sample HL7 Interface",
      "ip": "X.X.X.X",
      "port": 12212
    }
  ],
  "outputType": "file",
  "logFilePath": "C:\\Logs\\network_monitor.log"
}

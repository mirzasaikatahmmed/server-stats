# Server Stats Analyzer

A comprehensive bash script for analyzing and monitoring Linux server performance statistics in real-time.

## Overview

`server-stats.sh` is a lightweight, zero-dependency tool that provides detailed insights into your server's performance. It displays system information, resource usage, and top processes in a beautifully formatted, color-coded output.

## Features

### Core Statistics
- **CPU Usage**: Total CPU utilization with detailed breakdown (user, system, nice, idle, wait)
- **Memory Usage**: Total, used, free, and available memory with percentage and visual bar
- **Disk Usage**: Filesystem usage with color-coded warnings for all mounted drives
- **Top Processes**: Top 5 processes sorted by CPU and memory consumption

### System Information
- Operating system and kernel version
- System hostname
- Server uptime
- Load average (1, 5, and 15 minutes)
- Currently logged-in users with session details
- Failed login attempts (security monitoring)
- CPU core count
- Swap usage statistics

### Visual Features
- Color-coded output for better readability
- Visual progress bar for memory usage
- Warning colors for disk usage (red ≥90%, yellow ≥75%, green <75%)
- Warning colors for resource-intensive processes
- Clean, formatted tables and sections

## Requirements

- Linux-based operating system
- Bash shell (version 4.0 or higher recommended)
- Standard Linux utilities: `top`, `free`, `df`, `ps`, `who`, `uptime`

No additional dependencies or installations required.

## Installation

1. Clone or download the script:
```bash
git clone <repository-url>
cd server-stats
```

2. Make the script executable:
```bash
chmod +x server-stats.sh
```

## Usage

Run the script directly:
```bash
./server-stats.sh
```

Or from any location:
```bash
/path/to/server-stats.sh
```

### Running with Sudo

Some features (like failed login attempts) may require elevated privileges:
```bash
sudo ./server-stats.sh
```

### Creating an Alias

For convenience, add an alias to your `.bashrc` or `.zshrc`:
```bash
echo "alias serverstats='/path/to/server-stats.sh'" >> ~/.bashrc
source ~/.bashrc
```

Now you can run it with:
```bash
serverstats
```

## Output Sections

### 1. System Information
- OS version and kernel
- Hostname
- Uptime
- Load average
- Logged-in users
- Failed login attempts

### 2. CPU Usage
- Total CPU usage percentage
- CPU idle percentage
- Number of CPU cores
- Detailed breakdown by usage type

### 3. Memory Usage
- Total, used, free, and available memory
- Memory usage percentage
- Visual progress bar
- Swap usage statistics

### 4. Disk Usage
- Per-filesystem usage details
- Total disk space summary
- Color-coded warnings for high usage

### 5. Process Monitoring
- Top 5 processes by CPU usage
- Top 5 processes by memory usage
- Color-coded based on resource consumption

## Color Coding

- **Green**: Normal/healthy status
- **Yellow**: Warning (75-89% usage)
- **Red**: Critical (≥90% usage or high resource consumption)
- **Blue**: Section headers
- **Cyan**: Subsection headers

## Permissions

The script works without root privileges, but some features provide more information when run as root:
- Failed login attempts require read access to `/var/log/auth.log` or `/var/log/secure`

## Compatibility

Tested on:
- Ubuntu 20.04+
- Debian 10+
- CentOS 7+
- Red Hat Enterprise Linux 7+
- Fedora 30+

Should work on any Linux distribution with standard GNU utilities.

## Troubleshooting

### Script doesn't run
Ensure the script has execute permissions:
```bash
chmod +x server-stats.sh
```

### Missing utilities
Install required packages (example for Debian/Ubuntu):
```bash
sudo apt-get install procps coreutils util-linux
```

### No color output
Some terminals may not support ANSI color codes. Try running in a different terminal emulator.

### Failed login attempts not showing
Run the script with sudo to access system log files:
```bash
sudo ./server-stats.sh
```

## Use Cases

- **System Monitoring**: Quick overview of server health
- **Performance Troubleshooting**: Identify resource-hungry processes
- **Capacity Planning**: Track resource utilization trends
- **Security Auditing**: Monitor failed login attempts
- **Server Maintenance**: Pre/post-maintenance verification
- **Learning Tool**: Understand Linux system performance metrics

## Example Output

```
╔════════════════════════════════════════════════════════════════╗
║           SERVER PERFORMANCE STATISTICS ANALYZER              ║
╔════════════════════════════════════════════════════════════════╗

==================== SYSTEM INFORMATION ====================
OS: Ubuntu 24.04.3 LTS
Kernel: 6.14.0-37-generic
Hostname: production-server
Uptime: up 7 hours, 22 minutes
Load Average: 0.45, 0.60, 0.36

==================== CPU USAGE ====================
Total CPU Usage: 7.0%
CPU Cores: 12

==================== MEMORY USAGE ====================
Total Memory: 7.4Gi
Used Memory: 4.1Gi (54.93%)
[████████████████████████████░░░░░░░░░░░░] 54.93%

... and more
```

## Contributing

Contributions are welcome. Please ensure:
- Code follows existing style
- Changes are tested on multiple Linux distributions
- Documentation is updated accordingly

## License

MIT License - feel free to use and modify as needed.

## Author

Created as a learning project for understanding Linux server performance monitoring.

## Version History

- **v1.0.0** - Initial release with all core features and stretch goals

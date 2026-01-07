//
//  SystemMonitor.swift
//  Pownin-Assistant
//
//  Real-time system monitoring for Intel Mac
//

import Foundation
import Darwin

class SystemMonitor {
    static let shared = SystemMonitor()
    
    private init() {}
    
    /// Get current CPU usage percentage
    func getCPUUsage() -> Double {
        var cpuInfo: processor_info_array_t?
        var numCPUInfo: mach_msg_type_number_t = 0
        var numProcessors: natural_t = 0
        
        let result = host_processor_info(
            mach_host_self(),
            PROCESSOR_CPU_LOAD_INFO,
            &numProcessors,
            &cpuInfo,
            &numCPUInfo
        )
        
        guard result == KERN_SUCCESS, let cpuInfo = cpuInfo else {
            // Return 0.0 if unable to get real metrics
            print("Warning: Unable to retrieve CPU usage, returning 0.0")
            return 0.0
        }
        
        var totalUsage: Double = 0
        
        for i in 0..<Int(numProcessors) {
            let cpuLoadInfo = cpuInfo.advanced(by: Int(CPU_STATE_MAX) * i)
            let user = Double(cpuLoadInfo[Int(CPU_STATE_USER)])
            let system = Double(cpuLoadInfo[Int(CPU_STATE_SYSTEM)])
            let nice = Double(cpuLoadInfo[Int(CPU_STATE_NICE)])
            let idle = Double(cpuLoadInfo[Int(CPU_STATE_IDLE)])
            
            let total = user + system + nice + idle
            if total > 0 {
                totalUsage += ((user + system + nice) / total) * 100
            }
        }
        
        let avgUsage = totalUsage / Double(numProcessors)
        
        // Cleanup
        vm_deallocate(
            mach_task_self_,
            vm_address_t(bitPattern: cpuInfo),
            vm_size_t(numCPUInfo) * vm_size_t(MemoryLayout<integer_t>.stride)
        )
        
        return min(max(avgUsage, 0), 100)
    }
    
    /// Get current memory usage percentage
    func getMemoryUsage() -> Double {
        var stats = vm_statistics64()
        var count = mach_msg_type_number_t(MemoryLayout<vm_statistics64>.size / MemoryLayout<integer_t>.size)
        
        let result = withUnsafeMutablePointer(to: &stats) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics64(
                    mach_host_self(),
                    HOST_VM_INFO64,
                    $0,
                    &count
                )
            }
        }
        
        guard result == KERN_SUCCESS else {
            // Return 0.0 if unable to get real metrics
            print("Warning: Unable to retrieve memory usage, returning 0.0")
            return 0.0
        }
        
        let pageSize = vm_kernel_page_size
        
        let active = Double(stats.active_count) * Double(pageSize)
        let wired = Double(stats.wire_count) * Double(pageSize)
        let compressed = Double(stats.compressor_page_count) * Double(pageSize)
        
        // Get total physical memory
        var totalMemory: UInt64 = 0
        var size = MemoryLayout<UInt64>.size
        sysctlbyname("hw.memsize", &totalMemory, &size, nil, 0)
        
        guard totalMemory > 0 else {
            print("Warning: Unable to retrieve total memory, returning 0.0")
            return 0.0
        }
        
        let usedMemory = active + wired + compressed
        let memoryUsage = (usedMemory / Double(totalMemory)) * 100
        
        return min(max(memoryUsage, 0), 100)
    }
    
    /// Get system architecture information
    func getArchitecture() -> String {
        var sysinfo = utsname()
        uname(&sysinfo)
        
        let machine = withUnsafePointer(to: &sysinfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                String(cString: $0)
            }
        }
        
        return machine
    }
    
    /// Check if running on Intel Mac
    func isIntelMac() -> Bool {
        let arch = getArchitecture()
        return arch.contains("x86_64")
    }
}

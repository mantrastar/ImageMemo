//
//  SystemMem.h
//  ImageMemo
//
//  Created by Ven Jandhyala on 1/3/24.
//


#pragma once


/*

 The Idea here is to explore various low-level Memory Techniques, and
 to get a good Understanding of whether it is worthwhile to ever go
 beyond NSCache, and to its lower internal libcache (cache.h) Implementation,
 or... even lower into Mach and using direct Virtual Memory Allocations to
 try to get more granular Control over Cache Behavior and Memory Layout.
 
 For most Apps, just using NSCache should be more than sufficient - but,
 We may not be making "most Apps". Games and other high performance
 Systems may require real-time Performance or might otherwise be running
 in a Resource contrained Environment (Mobile Devices or Embedded Systems).
 
 In any Case, this is a valuable Experiment and the Plan is that some good
 Tools for testing and profiling Memory using the very realistic and Scenario
 of downloading Data from a Network asynchronously (could be small or big, and
 fast or slow), and persisting the Data to a Mix of RAM and Flash, for
 optimal System Efficiency and User Experience.

 
 Memory Cache
 -------------------------------------
 High Level : NSCache
 Mid Level  : libcache
 Low Level  : mach_vm
 
 Storage Cache
 -------------------------------------
 App Sandbox Filesystem
 |
 +-> Image Data
 |
 +-> Codable Data
 |
 +-> SQLite Database
 
*/

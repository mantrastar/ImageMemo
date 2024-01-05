//
//  SystemMem.h
//  ImageMemo
//
//  Created by Ven Jandhyala on 1/3/24.
//


#pragma once


/*

 Memory Systems
 -------------------------------------
 High Level : NSCache
 Mid Level  : libcache
 Low Level  : mach_vm
 
 Sandbox Storage
 -------------------------------------
 App Filesystem
 |
 +-> Image Data
 |
 +-> Codable Data
 |
 +-> SQLite Database
 
*/

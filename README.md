# qbcore-userverification
User verification entry script for QBCore based FiveM GTA 5 RP servers

## Requirements

* QBCore based FiveM GTA 5 RP Server
* oxmysql
* okokNotify

## Commands

* /permitentry - Verifies the nearest user and permits entry
* /denyentry - Denies the nearest user entry and bans that user for a certain period of time

## Installation

* Install requirements (see above)
* Register commands in qb-core/server/commands.lua by copying the file content to your server's qb-core/server/commands.lua
* Customize config values (config.lua) to your needs
* Install and enable this plugin
PayloadSpeedSettings = PayloadSpeedSettings or { }


PayloadSpeedSettings.flat = PayloadSpeedSettings.flat or { }
PayloadSpeedSettings.flat.pushed = PayloadSpeedSettings.flat.pushed or { }
PayloadSpeedSettings.flat.pushed.speed = 0.8
PayloadSpeedSettings.flat.pushed.bonus_speed_per_player = 0.05
PayloadSpeedSettings.flat.pushed.acceleration = 0.5

PayloadSpeedSettings.flat.not_pushed = PayloadSpeedSettings.flat.not_pushed or { }
PayloadSpeedSettings.flat.not_pushed.speed = 0
PayloadSpeedSettings.flat.not_pushed.acceleration = 0.5


PayloadSpeedSettings.uphill = PayloadSpeedSettings.uphill or { }
PayloadSpeedSettings.uphill.pushed = PayloadSpeedSettings.uphill.pushed or { }
PayloadSpeedSettings.uphill.pushed.speed = 0.4
PayloadSpeedSettings.uphill.pushed.bonus_speed_per_player = 0.05
PayloadSpeedSettings.uphill.pushed.acceleration = 1.2

PayloadSpeedSettings.uphill.not_pushed = PayloadSpeedSettings.uphill.not_pushed or { }
PayloadSpeedSettings.uphill.not_pushed.speed = -1
PayloadSpeedSettings.uphill.not_pushed.acceleration = 0.3


PayloadSpeedSettings.downhill = PayloadSpeedSettings.downhill or { }
PayloadSpeedSettings.downhill.pushed = PayloadSpeedSettings.downhill.pushed or { }
PayloadSpeedSettings.downhill.pushed.speed = 1.6
PayloadSpeedSettings.downhill.pushed.bonus_speed_per_player = 0.05
PayloadSpeedSettings.downhill.pushed.acceleration = 0.5

PayloadSpeedSettings.downhill.not_pushed = PayloadSpeedSettings.downhill.not_pushed or { }
PayloadSpeedSettings.downhill.not_pushed.speed = 1.2
PayloadSpeedSettings.downhill.not_pushed.acceleration = 0.2


PayloadSpeedSettings.muddy = PayloadSpeedSettings.muddy or { }
PayloadSpeedSettings.muddy.pushed = PayloadSpeedSettings.muddy.pushed or { }
PayloadSpeedSettings.muddy.pushed.speed = 0.7
PayloadSpeedSettings.muddy.pushed.bonus_speed_per_player = 0.05
PayloadSpeedSettings.muddy.pushed.acceleration = 0.5

PayloadSpeedSettings.muddy.not_pushed = PayloadSpeedSettings.muddy.not_pushed or { }
PayloadSpeedSettings.muddy.not_pushed.speed = 0
PayloadSpeedSettings.muddy.not_pushed.acceleration = 0.5


PayloadSpeedSettings.small_flat = PayloadSpeedSettings.small_flat or { }
PayloadSpeedSettings.small_flat.pushed = PayloadSpeedSettings.small_flat.pushed or { }
PayloadSpeedSettings.small_flat.pushed.speed = 1.8
PayloadSpeedSettings.small_flat.pushed.bonus_speed_per_player = 0.05
PayloadSpeedSettings.small_flat.pushed.acceleration = 0.5

PayloadSpeedSettings.small_flat.not_pushed = PayloadSpeedSettings.small_flat.not_pushed or { }
PayloadSpeedSettings.small_flat.not_pushed.speed = 0
PayloadSpeedSettings.small_flat.not_pushed.acceleration = 0.5


PayloadSpeedSettings.small_slowdown = PayloadSpeedSettings.small_slowdown or { }
PayloadSpeedSettings.small_slowdown.pushed = PayloadSpeedSettings.small_slowdown.pushed or { }
PayloadSpeedSettings.small_slowdown.pushed.speed = 0
PayloadSpeedSettings.small_slowdown.pushed.bonus_speed_per_player = 0
PayloadSpeedSettings.small_slowdown.pushed.acceleration = 0.5

PayloadSpeedSettings.small_slowdown.not_pushed = PayloadSpeedSettings.small_slowdown.not_pushed or { }
PayloadSpeedSettings.small_slowdown.not_pushed.speed = 0
PayloadSpeedSettings.small_slowdown.not_pushed.acceleration = 0.5


PayloadSpeedSettings.small_uphill = PayloadSpeedSettings.small_uphill or { }
PayloadSpeedSettings.small_uphill.pushed = PayloadSpeedSettings.small_uphill.pushed or { }
PayloadSpeedSettings.small_uphill.pushed.speed = 1.3
PayloadSpeedSettings.small_uphill.pushed.bonus_speed_per_player = 0.05
PayloadSpeedSettings.small_uphill.pushed.acceleration = 1.2

PayloadSpeedSettings.small_uphill.not_pushed = PayloadSpeedSettings.small_uphill.not_pushed or { }
PayloadSpeedSettings.small_uphill.not_pushed.speed = -2
PayloadSpeedSettings.small_uphill.not_pushed.acceleration = 0.5


PayloadSpeedSettings.small_downhill_slow = PayloadSpeedSettings.small_downhill_slow or { }
PayloadSpeedSettings.small_downhill_slow.pushed = PayloadSpeedSettings.small_downhill_slow.pushed or { }
PayloadSpeedSettings.small_downhill_slow.pushed.speed = 2
PayloadSpeedSettings.small_downhill_slow.pushed.bonus_speed_per_player = 0.05
PayloadSpeedSettings.small_downhill_slow.pushed.acceleration = 0.5

PayloadSpeedSettings.small_downhill_slow.not_pushed = PayloadSpeedSettings.small_downhill_slow.not_pushed or { }
PayloadSpeedSettings.small_downhill_slow.not_pushed.speed = 1
PayloadSpeedSettings.small_downhill_slow.not_pushed.acceleration = 0.2


PayloadSpeedSettings.small_downhill = PayloadSpeedSettings.small_downhill or { }
PayloadSpeedSettings.small_downhill.pushed = PayloadSpeedSettings.small_downhill.pushed or { }
PayloadSpeedSettings.small_downhill.pushed.speed = 2.5
PayloadSpeedSettings.small_downhill.pushed.bonus_speed_per_player = 0.05
PayloadSpeedSettings.small_downhill.pushed.acceleration = 0.5

PayloadSpeedSettings.small_downhill.not_pushed = PayloadSpeedSettings.small_downhill.not_pushed or { }
PayloadSpeedSettings.small_downhill.not_pushed.speed = 2
PayloadSpeedSettings.small_downhill.not_pushed.acceleration = 0.2


PayloadSpeedSettings.small_downhill_fast = PayloadSpeedSettings.small_downhill_fast or { }
PayloadSpeedSettings.small_downhill_fast.pushed = PayloadSpeedSettings.small_downhill_fast.pushed or { }
PayloadSpeedSettings.small_downhill_fast.pushed.speed = 3.5
PayloadSpeedSettings.small_downhill_fast.pushed.bonus_speed_per_player = 0.05
PayloadSpeedSettings.small_downhill_fast.pushed.acceleration = 0.5

PayloadSpeedSettings.small_downhill_fast.not_pushed = PayloadSpeedSettings.small_downhill_fast.not_pushed or { }
PayloadSpeedSettings.small_downhill_fast.not_pushed.speed = 3
PayloadSpeedSettings.small_downhill_fast.not_pushed.acceleration = 0.2


PayloadSpeedSettings.small_downhill_chase_01 = PayloadSpeedSettings.small_downhill_chase_01 or { }
PayloadSpeedSettings.small_downhill_chase_01.pushed = PayloadSpeedSettings.small_downhill_chase_01.pushed or { }
PayloadSpeedSettings.small_downhill_chase_01.pushed.speed = 7.5
PayloadSpeedSettings.small_downhill_chase_01.pushed.bonus_speed_per_player = 0
PayloadSpeedSettings.small_downhill_chase_01.pushed.acceleration = 4

PayloadSpeedSettings.small_downhill_chase_01.not_pushed = PayloadSpeedSettings.small_downhill_chase_01.not_pushed or { }
PayloadSpeedSettings.small_downhill_chase_01.not_pushed.speed = 7.5
PayloadSpeedSettings.small_downhill_chase_01.not_pushed.acceleration = 4


PayloadSpeedSettings.small_downhill_chase_02 = PayloadSpeedSettings.small_downhill_chase_02 or { }
PayloadSpeedSettings.small_downhill_chase_02.pushed = PayloadSpeedSettings.small_downhill_chase_02.pushed or { }
PayloadSpeedSettings.small_downhill_chase_02.pushed.speed = 6.5
PayloadSpeedSettings.small_downhill_chase_02.pushed.bonus_speed_per_player = 0
PayloadSpeedSettings.small_downhill_chase_02.pushed.acceleration = 3

PayloadSpeedSettings.small_downhill_chase_02.not_pushed = PayloadSpeedSettings.small_downhill_chase_02.not_pushed or { }
PayloadSpeedSettings.small_downhill_chase_02.not_pushed.speed = 6.5
PayloadSpeedSettings.small_downhill_chase_02.not_pushed.acceleration = 3


PayloadSpeedSettings.ussingen_downhill_mansion_01 = PayloadSpeedSettings.ussingen_downhill_mansion_01 or { }
PayloadSpeedSettings.ussingen_downhill_mansion_01.pushed = PayloadSpeedSettings.ussingen_downhill_mansion_01.pushed or { }
PayloadSpeedSettings.ussingen_downhill_mansion_01.pushed.speed = 6.5
PayloadSpeedSettings.ussingen_downhill_mansion_01.pushed.bonus_speed_per_player = 0
PayloadSpeedSettings.ussingen_downhill_mansion_01.pushed.acceleration = 3

PayloadSpeedSettings.ussingen_downhill_mansion_01.not_pushed = PayloadSpeedSettings.ussingen_downhill_mansion_01.not_pushed or { }
PayloadSpeedSettings.ussingen_downhill_mansion_01.not_pushed.speed = 6.5
PayloadSpeedSettings.ussingen_downhill_mansion_01.not_pushed.acceleration = 3


PayloadSpeedSettings.farmlands_heavy_load_01 = PayloadSpeedSettings.farmlands_heavy_load_01 or { }
PayloadSpeedSettings.farmlands_heavy_load_01.pushed = PayloadSpeedSettings.farmlands_heavy_load_01.pushed or { }
PayloadSpeedSettings.farmlands_heavy_load_01.pushed.speed = 0.2
PayloadSpeedSettings.farmlands_heavy_load_01.pushed.bonus_speed_per_player = 0.07
PayloadSpeedSettings.farmlands_heavy_load_01.pushed.acceleration = 1

PayloadSpeedSettings.farmlands_heavy_load_01.not_pushed = PayloadSpeedSettings.farmlands_heavy_load_01.not_pushed or { }
PayloadSpeedSettings.farmlands_heavy_load_01.not_pushed.speed = 0
PayloadSpeedSettings.farmlands_heavy_load_01.not_pushed.acceleration = 0.2



PayloadSpeedSettings.normal = PayloadSpeedSettings.normal or { }
PayloadSpeedSettings.normal.pushed = PayloadSpeedSettings.normal.pushed or { }
PayloadSpeedSettings.normal.pushed.speed = 2.5
PayloadSpeedSettings.normal.pushed.bonus_speed_per_player = 0.25
PayloadSpeedSettings.normal.pushed.acceleration = 0.25

PayloadSpeedSettings.normal.not_pushed = PayloadSpeedSettings.normal.not_pushed or { }
PayloadSpeedSettings.normal.not_pushed.speed = 0
PayloadSpeedSettings.normal.not_pushed.acceleration = 0.25




PayloadSpeedSettings.sled_normal = PayloadSpeedSettings.sled_normal or { }
PayloadSpeedSettings.sled_normal.pushed = PayloadSpeedSettings.sled_normal.pushed or { }
PayloadSpeedSettings.sled_normal.pushed.speed = 1.85
PayloadSpeedSettings.sled_normal.pushed.bonus_speed_per_player = 0.75
PayloadSpeedSettings.sled_normal.pushed.acceleration = 1.75

PayloadSpeedSettings.sled_normal.not_pushed = PayloadSpeedSettings.sled_normal.not_pushed or { }
PayloadSpeedSettings.sled_normal.not_pushed.speed = 0
PayloadSpeedSettings.sled_normal.not_pushed.acceleration = 1.75


PayloadSpeedSettings.sled_fast = PayloadSpeedSettings.sled_fast or { }
PayloadSpeedSettings.sled_fast.pushed = PayloadSpeedSettings.sled_fast.pushed or { }
PayloadSpeedSettings.sled_fast.pushed.speed = 8
PayloadSpeedSettings.sled_fast.pushed.bonus_speed_per_player = 0
PayloadSpeedSettings.sled_fast.pushed.acceleration = 3

PayloadSpeedSettings.sled_fast.not_pushed = PayloadSpeedSettings.sled_fast.not_pushed or { }
PayloadSpeedSettings.sled_fast.not_pushed.speed = 8
PayloadSpeedSettings.sled_fast.not_pushed.acceleration = 2


PayloadSpeedSettings.sled_downhill = PayloadSpeedSettings.sled_downhill or { }
PayloadSpeedSettings.sled_downhill.pushed = PayloadSpeedSettings.small_downhill.pushed or { }
PayloadSpeedSettings.sled_downhill.pushed.speed = 5.5
PayloadSpeedSettings.sled_downhill.pushed.bonus_speed_per_player = 0.5
PayloadSpeedSettings.sled_downhill.pushed.acceleration = 2.5

PayloadSpeedSettings.sled_downhill.not_pushed = PayloadSpeedSettings.sled_downhill.not_pushed or { }
PayloadSpeedSettings.sled_downhill.not_pushed.speed = 5
PayloadSpeedSettings.sled_downhill.not_pushed.acceleration = 1.75

PayloadSpeedSettings.sled_fast02 = PayloadSpeedSettings.sled_fast02 or { }
PayloadSpeedSettings.sled_fast02.pushed = PayloadSpeedSettings.sled_fast02.pushed or { }
PayloadSpeedSettings.sled_fast02.pushed.speed = 9
PayloadSpeedSettings.sled_fast02.pushed.bonus_speed_per_player = 0
PayloadSpeedSettings.sled_fast02.pushed.acceleration = 4

PayloadSpeedSettings.sled_fast02.not_pushed = PayloadSpeedSettings.sled_fast02.not_pushed or { }
PayloadSpeedSettings.sled_fast02.not_pushed.speed = 9
PayloadSpeedSettings.sled_fast02.not_pushed.acceleration = 4


PayloadSpeedSettings.tiny_uphill = PayloadSpeedSettings.tiny_uphill or { }
PayloadSpeedSettings.tiny_uphill.pushed = PayloadSpeedSettings.tiny_uphill.pushed or { }
PayloadSpeedSettings.tiny_uphill.pushed.speed = 1.45
PayloadSpeedSettings.tiny_uphill.pushed.bonus_speed_per_player = 0.25
PayloadSpeedSettings.tiny_uphill.pushed.acceleration = 0.75

PayloadSpeedSettings.tiny_uphill.not_pushed = PayloadSpeedSettings.tiny_uphill.not_pushed or { }
PayloadSpeedSettings.tiny_uphill.not_pushed.speed = -1.75
PayloadSpeedSettings.tiny_uphill.not_pushed.acceleration = 1.2
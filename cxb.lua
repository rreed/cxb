function _init()
  frame = 0
  targets = {}
  arrows = {}
  mouse_x = 64
  mouse_y = 64
  
  -- a "click" lasts for four frames i guess
  mouse_click = false
  mouse_frame = 0
  score = 0
  
  -- mouse enabling shenanigans
  -- this is required once for reading any mouse inputs
  -- don't ask me why :)
  poke(0x5f2d, 1)
  
  title_screen()
end

function title_screen()
  _update = update_title
  _draw = draw_title
end
  
function start_game()
  _update = update_game
  _draw = draw_game
end
  
function draw_title()
  -- incredibly fancy static title screen
  cls()
  print("title screen",40,34,4)
  print("left mouse to start", 26, 54, 4)
  print("click targets within one second", 3, 74, 4)
end
  
function update_title()
  -- check left mouse click
  if stat(34) == 1 then start_game() end 
end

function draw_game()
  cls()
  
  -- draw targets
  for t in all(targets) do
    spr(t.sp, t.x, t.y)
  end 
  
  -- draw "arrows"
  for a in all(arrows) do
    spr(a.sp, a.x, a.y)
  end
  
  -- draw mouse cursor
  spr(2, mouse_x-4, mouse_y-4)
  
  -- draw score
  print(score,1,1,1)
end

function update_game()
  frame += 1
  if (frame % 30 == 0) then
    sfx(2)
    spawn_target()
  end
  
  mouse_x = stat(32)
  mouse_y = stat(33)
  
  mouse_down = (stat(34) == 1)
  if mouse_down and not mouse_click then
    mouse_click = true
  end
  
  if mouse_click then
    mouse_frame += 1
  end

  -- four frames later, they didn't click "recently"  
  if mouse_frame > 4 then
    mouse_click = false
    mouse_frame = 0
  end
  
  -- check "collisions" for all targets
  -- also nuke any that are thirty frames old
  for t in all(targets) do
    check_clicked(t)
    t.f += 1
    
    if t.f == 30 then del(targets, t) end
  end
  
  -- move all arrows
  -- nuke any that are thirty frames old
  for a in all(arrows) do
    a.x += a.dx
    a.y += a.dy  
    a.f += 1
    
    if a.f == 30 then del(arrows, a) end
  end
end

-- calculates the in-game bounding box of a sprite
-- considers the sprite's box + the sprite's in-game position
function abs_box(s)
  local box = {}
  box.x1 = s.box.x1 + s.x
  box.x2 = s.box.x2 + s.x
  box.y1 = s.box.y1 + s.y
  box.y2 = s.box.y2 + s.y
  return box
end

-- return true if a click lands inside a target
-- false otherwise
-- also handles target deletion
function check_clicked(t)
  -- if the mouse isn't "down", obviously nothing was clicked
  if not mouse_click then return false end
  local tbox = abs_box(t)
  
  if mouse_x > tbox.x1
  and mouse_y > tbox.y1
  and mouse_x < tbox.x2
  and mouse_y < tbox.y2
  then
    score += 1
    sfx(1)
    del(targets, t)
    -- could also delete the associated arrows here...
    -- eh, effort :)
    return true -- not checked, probably still good
  end
  return false
end

-- spawn a click target
-- 10 < x < 118
-- 10 < y < 118
-- bounding box is the "outer ring"
function spawn_target()
  -- 10 to 118
  local target = {
   sp= 1,
  	x=rnd(108) + 10,
  	y=rnd(108) + 10,
  	box={x1=1,y1=1,x2=6,y2=6},
  	f=0
  }
  add(targets, target)
  
  spawn_arrows(target)
end

-- spawn four arrows that move towards the center of target "t"
-- no collision detection
-- just sick graphics bro!!
function spawn_arrows(t)
  local ul = {sp=3,dx=1,dy=1,x=t.x-30,y=t.y-30,f=0}
  local ur = {sp=4,dx=-1,dy=1,x=t.x+30,y=t.y-30,f=0}
  local bl = {sp=19,dx=1,dy=-1,x=t.x-30,y=t.y+30,f=0}
  local br = {sp=20,dx=-1,dy=-1,x=t.x+30,y=t.y+30,f=0}
  
  add(arrows, ul)
  add(arrows, ur)
  add(arrows, bl)
  add(arrows, br)
end

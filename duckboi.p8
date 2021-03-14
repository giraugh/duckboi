pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
cam = {
	x = 0,
	y = 0,
	ox = -6,
	oy = -10
}

pl = {
	x = 64,
	y = 50,
	vx = 0,
	vy = 0,
	wf = 0,
	wft = 0,
	wftm = 3,
	vd = .9,
	li = 1,
	active = true,
	br = 10,
	brm = 10,
	rt = -1,
	flsh = 0
}

bullets = {}
parts = {}
ducks = {}
splats = {}
aliens = {}
eggs = {}
goliaths = {}

al_spt = 0
al_sptm = 100
score = 0
game_over = false

function make_goliath(x,y)
	add(goliaths, {
		x = x,
		y = y,
		li = 1,
		wf = 0,
		wft = 0,
		wftm = 4,
		hth = 5,
		hfx = 0
	})
end

function make_egg(x,y)
	add(eggs,{
		x = x,
		y = y,
		t = 0,
		tm = 300
	})
end

function make_alien(x,y)
	add(aliens,{
		x = x,
		y = y,
		li = 1,
		wf = 0,
		wft = 0,
		wftm = 4
	})
end

function make_splat(s,x,y,lt)
	add(splats,{
		x = x,
		y = y,
		s = s,
		lt = lt or -1
	})
end

function make_duck(x,y)
	add(ducks, {
		x = x,
		y = y,
		wf = 0,
		wft = 0,
		wftm = 5,
		quack = function(this,ix)
			sfx(7)
 		sfx(8)
 		make_parts(3,16,
 			this.x,this.y,(ix or 0)*.7,15)
		end
	})
end

function make_parts(amt,s,x,y,xb,lt)
	for i=1,amt do
		add(parts, {
			x = x,
			y = y,
			s = s,
			vx = xb*1.5+(rnd()*2)-1,
			vy = (rnd()*2)-1,
			lt = lt or 10
		})
	end
end

function make_bullet(x,y,li)
	add(bullets, {
		x = x,
		y = y,
		li = li,
		vx = li,
		vy = ((rnd()*2)-1)/10,
		spd = 4
	})
end

----

function _init()
 spawn_ducks()
end

---

function _update()
 upd_pl()
 upd_bullets()
 upd_cam()
 upd_parts()
 upd_ducks()
 upd_aliens()
 upd_splats()
 upd_eggs()
 upd_goliaths()
 spawning()
 check_loss()
 restart()
end

function restart()
	if game_over then
		if btnp(❎) and btnp(🅾️) then
			game_over = false
			splats = {}
			aliens = {}
			eggs = {}
			goliaths = {}
			score = 0
			al_sptm = 100
			pl.active = true
			pl.x = 64
			pl.y = 64
			spawn_ducks()
		end
	end
end

function spawn_ducks()
 for i=1,9 do
  local xx=20+rnd()*70
  local yy=40+rnd()*40
 	make_duck(xx,yy)
 end
end

function upd_eggs()
	for e in all(eggs) do
		e.t += 1
	 if e.t > e.tm then
	 	del(eggs, e)
	 	sfx(15)
	 	make_duck(e.x, e.y)
	 	make_parts(5,49,e.x,e.y,0,10)
	 end
	 
	 -- get hit by bullets
 	local me = {
	 	x = e.x, y = e.y-2,
	 	w = 8, h = 10
 	}
 	for b in all(bullets) do
 	 local them = {
 	 	x = b.x, y = b.y+4,
 	 	w = 8, h = 4
	 	}
	 	if recs_overlap(me,them) then
	 		make_parts(7, 23, e.x, e.y, b.vx/4, 15)
 		 make_parts(4, 19, e.x, e.y, 0, 20)
 		 for i=1,2 do
 		  local rx,ry=(rnd()*4)-2,(rnd()*4)-2
 		  make_splat(24+rnd()*2, e.x+rx, e.y+ry)
 		 end
 		 sfx(9)
 		 sfx(10)
 		 sfx(11)
 		 del(eggs, e)
 		 del(bullets, b)
 		 score -= 20
	 	end
 	end
	end
end

function check_loss()
 if not game_over then
	 if #ducks == 0 then
			pl.active = false
			al_sptm = 40
			make_parts(20, 23, pl.x-4, pl.y, 0, 20)	
			pl.x = 64
			pl.y = 64
			game_over = true
		end
	end
end

function spawning()
 al_spt += 1
 if al_spt > al_sptm then
  al_spt = 0
  if al_sptm > 35 then
   al_sptm -= 3
  end
  yo = ((rnd()*2)-1)*30
  if rnd() < .1 and al_sptm < 50 and #goliaths < 2 then
			make_goliath(
				rnd() < .5 and -10 or 128,
				50+yo
			)
		else
			make_alien(
				rnd() < .5 and -10 or 128,
				50+yo
			)
		end
	end
end

function upd_goliaths()
	for a in all(goliaths) do
		a.wft += 1
		if a.wft > a.wftm then
			a.wf = (a.wf+1)%2
			a.wft = 0
			
			local ix,iy = 0,0
			ix = sgn(pl.x - a.x)
		 iy = sgn(pl.y - a.y)
		 
		 a.x += ix * 1
	 	a.y += iy * 1
	 	a.x += rnd() * .3
	 	a.li = sgn(ix)
		end
		
		-- flashing pointer
		if not a.hd and a.wft % 2 == 0 then
			if a.x < -3 then
				spr(51, 1, a.y)
			end
			if a.x > 120 then
				spr(51, 114, a.y, 1, 1, true)
			end
		end
		
		-- stay below wall
	 if a.y < 27 then
 		a.y = 27
 	end
 	
 	-- define my coll
	 local me = {
	 	x = a.x, y = a.y+7,
	 	w = 8, h = 5
 	}
 	
 	-- squish ducks
 	for e in all(ducks) do
 		local them = {
 			x = e.x, y = e.y,
 			w = 5, h = 4
 		}
 		if recs_overlap(me,them) then
 			make_parts(10, 23, e.x, e.y, 0, 15)
 		 make_parts(5, 19, e.x, e.y, 0, 20)
 		 for i=1,3 do
 		  local rx,ry=(rnd()*4)-2,(rnd()*4)-2
 		  make_splat(24+rnd()*2, e.x+rx, e.y+ry)
 		 end
 		 sfx(9)
 		 sfx(10)
 		 del(ducks, e)
 		end
 	end
	 
	 -- hit by bullet?
 	for b in all(bullets) do
 	 local them = {
 	 	x = b.x, y = b.y+4,
 	 	w = 8, h = 4
 	 }
 	 if recs_overlap(me,them) then
 	 	a.hfx = 1
 	 	a.hth -= 1
 	 	sfx(10)
 	 	del(bullets, b)
 	 	if a.hth <= 0 then
	 	 	make_parts(20, 23, a.x, a.y, b.vx/4, 15)
	 			make_parts(20, 26, a.x, a.y, b.vx/4, 15)
	 			make_parts(20, 23, a.x+8, a.y, b.vx/4, 15)
	 			make_parts(20, 26, a.x+8, a.y, b.vx/4, 15)
	 			for i=1,6 do
	 		  local rx,ry=(rnd()*4)-2,(rnd()*4)-2
	 		  make_splat(36, a.x+rx, a.y+ry+8)
	 		  make_splat(36, a.x+rx+5, a.y+ry+8)
	 		 end
 	 		del(goliaths, a)
 	 		score += 50
 	 	end
 	 end
 	end
	end
end

function upd_aliens()
	for a in all(aliens) do
	 a.wft += 1
	 if a.wft > a.wftm then
	  a.wf = (a.wf+1)%2
	 	a.wft = 0
	 	
	 	local ix,iy = 0,0
	 	if a.hd then
	 		if a.x < 64 then
	 			ix = -2
	 		else
	 		 ix = 2
	 		end
	 	else
				ix = sgn(pl.x - a.x)
		 	iy = sgn(pl.y - a.y)
	 	end
	 	
	 	a.x += ix * 1.5
	 	a.y += iy * 1.5
	 	a.x += rnd()
	 	a.li = sgn(ix)
	 	make_splat(40, a.x-a.li*2, a.y-1, 80)
	 end
	 
	 -- stay below wall
	 if a.y < 27 then
 		a.y = 27
 	end
	 
	 -- define my coll
	 local me = {
	 	x = a.x, y = a.y-2,
	 	w = 8, h = 10
 	}
	 
	 -- hit by bullet?
 	for b in all(bullets) do
 	 local them = {
 	 	x = b.x, y = b.y+4,
 	 	w = 8, h = 4
 	 }
 		if recs_overlap(me,them) then
 			make_parts(10, 23, a.x, a.y, b.vx/4, 15)
 			make_parts(10, 26, a.x, a.y, b.vx/4, 15)
 			sfx(10)
 			for i=1,3 do
 		  local rx,ry=(rnd()*4)-2,(rnd()*4)-2
 		  make_splat(36, a.x+rx, a.y+ry)
 		 end
 			del(bullets, b)
 			del(aliens, a)
 			score += 10
			end
		end
		
		-- pick up ducks
		if not a.hd then
			for d in all(ducks) do
				local them = {
	 	 	x = d.x, y = d.y+4,
	 	 	w = 8, h = 4
	 	 }
	 	 if recs_overlap(me,them) then
	 	 	a.hd = d
	 	 end
	 	 
	 	 -- they should be scared!
	 	 -- quack?
		 	if cdist(a,d) < 30 and rnd() < .01 then
		 	 d:quack()
		 	end
			end
		end
		
		if a.hd then
			a.hd.x = a.x+a.li*4
			a.hd.y = a.y
			if rnd() < .05 then
			 if a.hd.quack then
		  	a.hd:quack()
		  end
		 end
		 if a.x < -20 or a.x > 128 then
	 		del(aliens, a)
	 		if a.hd == pl then
	 			pl.x = 64
	 			pl.y = 64
	 			pl.active = false
	 			pl.rt = 30
	 		end
	 	end
		end
		
		-- pick up pl?
		if not a.hd and pl.active then
			local plc = {
				x = pl.x, y = pl.y,
				w = 8, h = 8
			}
			if recs_overlap(me, plc) then
				a.hd = pl
				sfx(17)
			end
		end
	end
end

function upd_splats()
	for s in all(splats) do
	 if s.lt > 0 then
	 	s.lt -= 1
	 end
		if s.lt == 0 then
			del(splats, s)
		end
	end
end

function upd_ducks()
 for e in all(ducks) do
  e.wft += 1
  if e.wft > e.wftm then
   e.wft = 0
   e.wf = (e.wf+1)% 2
   
   -- towards player
	 	ix = sgn(pl.x - e.x)
	 	iy = sgn(pl.y - e.y)
	 	e.x += ix*.7
	 	e.y += iy*.7
	 	e.li = sgn(ix)
	 	
	 	for oe in all(ducks) do
	 		if e != oe then
	 		 local sep = .1
	 			e.x -= sgn(oe.x - e.x) * sep
	 			e.y -= sgn(oe.y - e.y) * sep
	 		end
	 	end
 	end
 	
 	-- off screen?
 	if e.x < 0 or e.x > 128 then
 		del(ducks, e)
 	end
 	
 	-- stay below wall
 	if e.y < 27 then
 		e.y = 27
 	end
 	
 	-- lay an egg
 	if #ducks < 6 and #eggs < 1 then
 		if rnd() < .002 then
 		 sfx(14)
 			make_egg(e.x,e.y)
 			make_parts(5,19,e.x,e.y,0,25)
 		end
 	end
 	
 	-- random qucaking
 	if rnd() < .0011 and e.wf==0 then
 		e:quack()
 	end
 	
 	-- hit by bullet? / dodge
 		local me = {
 	 	x = e.x, y = e.y-2,
 	 	w = 8, h = 10
	 	}
	 	for b in all(bullets) do
	 	 -- dodge
	 	 if cdist(b,e) < 32 then
		 	 e.x -= sgn(b.x - e.x)*.1
		 	 e.y -= sgn(b.y - e.y)*.2
	 	 end
	 	 local them = {
	 	 	x = b.x, y = b.y+4,
	 	 	w = 8, h = 4
	 	 }
	 		if recs_overlap(me,them) then
	 			make_parts(10, 23, e.x, e.y, b.vx/4, 15)
	 		 make_parts(5, 19, e.x, e.y, 0, 20)
	 		 for i=1,3 do
	 		  local rx,ry=(rnd()*4)-2,(rnd()*4)-2
	 		  make_splat(24+rnd()*2, e.x+rx, e.y+ry)
	 		 end
	 		 sfx(9)
	 		 sfx(10)
	 		 sfx(11)
	 		 del(ducks, e)
	 		 del(bullets, b)
	 		 score -= 25
	 		end
	 	end
 end
end

function upd_cam()
	cam.x = lerp(cam.x, cam.ox, .2)
	cam.y = lerp(cam.y, cam.oy, .2)
end

function upd_bullets()
	for b in all(bullets) do
	 b.x += b.vx*b.spd
	 b.y += b.vy*b.spd
	 if b.x < -10 or b.y < -10 or b.x > 138 or b.y > 138 then
	  del(bullets, b)
	 end
	end
end

function upd_parts()
	for p in all(parts) do
		p.x += p.vx
		p.y += p.vy
		p.lt -= 1
		if p.lt <= 0 then
			del(parts, p)
		end
	end
end

function upd_pl()

	if not pl.active then
	 if pl.rt > 0 then
	 	pl.rt -= 1
	 	if pl.rt == 0 then
	 		pl.active = true
	 		pl.flsh = 20
	 	end
	 end
		return
	end

 local ix,iy = 0,0
	if btn(➡️) then
		ix += 1
	end
	if btn(⬅️) then
  ix -= 1	
	end
	if btn(⬆️) then
		iy -= 1
	end
	if btn(⬇️) then
		iy += 1
	end
	
	if ix != 0 or iy != 0 then
	 pl.wft += 1
	 if pl.wft > pl.wftm then
		 pl.wf = (pl.wf+1)%2
			pl.wft = 0
			sfx(0)
		end
	end
	
	pl.li = ix != 0 and ix or pl.li
	
	-- accelerate
	pl.vx += ix
	pl.vy += iy
	
	-- displace
	pl.x += pl.vx
	pl.y += pl.vy
	
	-- damp
	pl.vx = pl.vx * (1-pl.vd)
	pl.vy = pl.vy * (1-pl.vd)
	if abs(pl.vx) < .002 then pl.vx = 0 end
	if abs(pl.vy) < .002 then pl.vy = 0 end

 -- stay on screen
 if pl.x < 0 then
 	pl.vx += .8
 	if pl.x < -3 then
 		pl.vx += .2
 	end
 end
 if pl.x > 115 then
 	pl.vx -= .8
 	if pl.x > 118 then
 		pl.vx -= .2
 	end
 end
 if pl.y < 27 then
 	pl.vy += 1
 end

 --shooting
 if btnp(❎) then
 	make_bullet(pl.x,pl.y,pl.li)
 	
 	--knockback
 	pl.vx -= pl.li * 1
 	
 	-- fx
 	shake(3)
 	make_parts(3, 19, pl.x+pl.li*4, pl.y, pl.li)
  sfx(1)
  sfx(2)
  sfx(6)
 end
 
 --yell
 if btnp(🅾️) then
  if pl.br > 0.1 then
   pl.br -= 2
	  for d in all(ducks) do
	  	d.x += 1*sgn(pl.x-d.x)
	  	d.y += 2*sgn(pl.y-d.y)
	  end
		 sfx(13)
		 sfx(12)
		 local p = 48
		 if pl.br < pl.brm/2 then
		 	p = 50
		 end
		 make_parts(
		 	7 * (pl.br/pl.brm),p,pl.x,pl.y,pl.li*.1,25)
  end
 else
 	pl.br = min(pl.br+.1, pl.brm)
 end

end

-----

function _draw()
 camera(cam.x, cam.y)
 cls()
 map()
 draw_splats()
 draw_shadows()
	draw_bullets()
	draw_parts()
	draw_eggs()
	draw_aliens()
	draw_ducks()
	draw_goliaths()
	if pl.active then draw_pl() end
	
	-- borders
	rectfill(-10, -10, -1, 128, 0)
	rectfill(-10, 100, 128, 120,0)
	rectfill(128, -10, 158, 138, 0)

 -- score
 print(
 	"score: " .. score,
 	2, 104, score >= 0 and 7 or 8)

 -- breath meter
 if pl.active then
  for i = 1, pl.br do
 	 spr(48, 85 + i*3, 103, 1, 1)
 	end
 end
 
 -- title
 print("duckboi", 3, -7, 1)

 -- game over
 if game_over then
  if flr(time()*2) % 2 == 0 then
	 	pal(8, 2)
	 end
	 
  local s = "game over!"
  print(s, 39, 50, 1)
  print(s, 41, 50, 1)
  print(s, 40, 51, 1)
  print(s, 40, 49, 1)
 	print(s, 40, 50, 8)
 	
 	print(
 	"press 🅾️ and ❎ to restart",
 	 10, 60, 7)
 	
 	pal()
 end

end

function draw_shadows()
	for e in all(eggs) do
		spr(17, e.x, e.y+1)
	end
	for a in all(aliens) do
	 spr(35, a.x-1, a.y+1)
	end
	for d in all(ducks) do
	 spr(17, d.x, d.y+1)
	end
	for a in all(goliaths) do
		spr(35, a.x+2, a.y+9)
		spr(35, a.x+5, a.y+9)
	end
	if pl.active then
		spr(17, pl.x, pl.y+1)
	end
end

function draw_goliaths()
	for a in all(goliaths) do
	 local s = a.wf == 0 and 11 or 43 
		local oy = (sin(time()*2)+1)/2
		
		if a.hfx > 0 then
			a.hfx -= 1
			pal(14, 7)
			pal(2, 6)
		end
		
		spr(s, a.x, a.y, 2, 2, a.li==-1)
	 spr(13, a.x+a.li*2-a.wf, a.y+9, 2, 1, a.li==-1)
	end
end

function draw_eggs()
	for e in all(eggs) do
	 local ox = 0
	 if e.t/e.tm > .6 then
	 	ox = e.t % 5 == 0 and rnd() or 0
	 end
		if e.t/e.tm > .85 then
			ox += e.t % 2 == 0 and (rnd()*2)-1 or 0
		end
		if abs(ox) > .5 then sfx(16) end
		spr(37, e.x+ox, e.y)
	end
end

function draw_aliens()
	for a in all(aliens) do
	 oy = (sin(time()*2)+1)/2
		spr(32+a.wf, a.x, a.y, 1, 1, a.li==-1)
	 spr(34, a.x+a.li, a.y+oy, 1, 1, a.li==-1)
		
		-- flashing pointer
		if not a.hd and a.wft % 2 == 0 then
			if a.x < -3 then
				spr(51, 1, a.y)
			end
			if a.x > 120 then
				spr(51, 114, a.y, 1, 1, true)
			end
		end
	end
end

function draw_splats()
	for s in all(splats) do
	 if s.lt < 5 then
	 	pal(14, 2)
	 end
		spr(s.s, s.x, s.y)
		pal()
	end
end

function draw_ducks()
 --duck bodies
	for e in all(ducks) do
		spr(20+e.wf, e.x, e.y, 1, 1, e.li==1)
	 spr(22, e.x, e.y+e.wf, 1, 1, e.li==1)
	end
end

function draw_bullets()
	for b in all(bullets) do
		spr(18, b.x, b.y, 1, 1, b.li)
	end
end

function draw_parts()
	for p in all(parts) do
	 if p.lt < 3 then
	  pal(6, 5)
	  pal(7, 6)
	  pal(8, 2)
	  pal(2, 1)
	 end
		spr(p.s, p.x, p.y)
		pal()
	end
end

function draw_pl()
 local ism = pl.vx != 0 or pl.vy != 0

	if pl.flsh != 0 and flr(time()*10) % 2 == 0 then
		pl.flsh -= 1
		return
	end 

 -- player
	spr(1+pl.wf, pl.x, pl.y)
	spr(3, pl.x, pl.y, 1, 1, pl.li==-1)
 
 -- hat
 local ho = ism and pl.wf or 0
 spr(4, pl.x, pl.y - 7 - ho)

 --gun
 go = ism and (sin(time()*2)+1)/2 or 0
 spr(5, pl.x + pl.li*2, pl.y-go, 1, 1, pl.li==-1)
end


-----

function shake(amt)
	cam.x += (rnd() * amt)-amt/2
	cam.y += (rnd() * amt)-amt/2
end

function lerp(a,b,t)
	return a + (b-a)*t
end

function recs_overlap(a, b)
 -- {
 --   x, y, w, h
 -- }
 
 local ax1,bx1 = a.x,b.x
 local ax2,bx2 = a.x+a.w,b.x+b.w
 local ay1,by1 = a.y,b.y
 local ay2,by2 = a.y+a.h,b.y+b.h
 
 return ax1 < bx2 and
        ax2 > bx1 and
        ay1 < by2 and
        ay2 > by1
end

function cdist(a,b)
	return sqrt(
		(a.x-b.x)^2 + (a.y-b.y)^2
	)
end
__gfx__
0000000000000000000000000888888000000000000000000000000000000000dd1ddddddddddddd000000000000000000000000000000000000000000000000
0000000000000000000000000822228000000000000000000000000000000000dd1ddddddddddddd000000000000000000000000000e20000000000000000000
0070070000000000000000000822c28000000000000000000bb77bb00000a000dd1ddddddddddddd00000000000000000e00000e000eee000000000000000000
0007700000000000000000000822228000777700000000000bb77bb0000a9a0011111111dddddddd00000000000000000ee000ee000eeeeeeee0000000000000
00077000000000000000000008222280007777000000aaa00bb77bb0000a9a00dddddd1ddddddddd00000000000000000eeeeeee00000eeeeeeee00000000000
00700700008888000088880000000000008888000000a000000000000000a000dddddd1ddddddddd00000000000000e02eeeeeee000000000000000000000000
0000000000800800008008000000000007777770000000000000000000000000dddddd1ddddddddd0000000000e002ee2ee22e22000000000000000000000000
000000000080000000000800000000000000000000000000000000000000000011111111dddddddd0000000000ee22222eeeeeee000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000022e22222eeeeeee000000000000000000000000
0000000000000000000000000000000000000000000000000070000000000000000000000000000000000000ee22222222eeeee0000000000000000000000000
00007000000000000000000000000000000000000000000007170000000000000000000000000000000000000222222222222000000000000000000000000000
0000700000000000009aaa00000070000000000000000000997777700008800000000000000000000000e0000022222222222000000000000000000000000000
0000700000000000009aaa0000077700000000000000000000677760000888000088880000222200000eee000022222202220000000000000000000000000000
0000000000111100009aaa00000070000007660000066700000000000000800008888880022222200000e0000002222000020000000000000000000000000000
00007000011111100000000000000000000706000006070000000000000000000088880000222200000000000002220000000000000000000000000000000000
00000000001111000000000000000000000006000006000000000000000000000000000000000000000000000000200000000000000000000000000000000000
00000e0e00000e0e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000eeee0000eeee000000000000000000000000000000000007700000000000000000000000000000000000000000000e00000e000000000000000000000000
0022e2e20022e8e8000000000000000000000000000000000077770000000000000000000000000000000000000000000ee000ee000000000000000000000000
2222eeee2222eeee020000000000000000000000000770000077770000000000000000000000000000000000000000000eeeeeee000000000000000000000000
22222ee222222ee20e0000000000000000eeee00006770000677777000000000000000000000000000000000000000e00eeeeeee000000000000000000000000
22222220222222200eeee000011111100eeeeee000677700066777700000000000000000000000000000000000e000ee2ee88e88000000000000000000000000
2202200022022000000000001111111100eeee0000667700066677700000000000000000000000000000000000ee02222eeeeeee000000000000000000000000
0200000000002000000000000111111000000000000660000066660000000000010001000000000000000000002e22222eeeeeee000000000000000000000000
000cc00000000000000000000000000000000000000000000000000000000000000000000000000000000000e222222222eeeee0000000000000000000000000
000cc00000000770000c0000000e0000000000000000000000000000000000000000000000000000000000000e22222222222200000000000000000000000000
000cc00000077770000c000000ee0000000000000000000000000000000000000000000000000000000000000222222222222000000000000000000000000000
000cc00000077770000c00000eee0000000000000000000000000000000000000000000000000000000000000022222222222000000000000000000000000000
0000000000777770000000000eee0000000000000000000000000000000000000000000000000000000000000002222022220000000000000000000000000000
000cc00000777700000c000000ee0000000000000000000000000000000000000000000000000000000000000000220022200000000000000000000000000000
000cc0000000000000000000000e0000000000000000000000000000000000000000000000000000000000000000000002200000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000
__label__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000dd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddd000
00000dd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddd000
00000dd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddd000
00000111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111000
00000dddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1d000
00000dddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1d000
00000dddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1d000
00000111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111000
00000dd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddd000
00000dd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddd000
00000dd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddd000
00000111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111000
00000dddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1d000
00000dddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1d000
00000dddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1d000
00000111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111000
00000dd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddd000
00000dd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddd000
00000dd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddd000
00000111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111000
00000dddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1d000
00000dddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1d000
00000dddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1d000
00000111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111000
00000dd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddd000
00000dd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddd000
00000dd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddd000
00000111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111000
00000dddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1d000
00000dddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1d000
00000dddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1d000
00000111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111000
00000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd000
00000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd000
00000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd000
00000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd000
00000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd000
00000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd000
00000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd000
00000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd000
00000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd000
00000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd000
00000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd000
00000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd000
00000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd000
00000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd000
00000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd7777d7dddddddddddddddddddddddddddddddddddddddddddddddd000
00000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd7777717ddddddddddddddddddddddddddddddddddddddddddddddd000
00000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd8888977777dddddddddddddddddddddddddddddddddddddddddddd000
00000ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd77777767776ddddddddddddddddddddddddddddddddddededdddddd000
00000ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd888888d766ddd7dddddddddddddddddddddddddddddddeeeedddddd000
00000ddddddddddddddddddddddddddddddddddddddddd7dddddddddddddddddddddd78222281716dd717dddddddddddddddddddddddddddddd8e8e22dddd000
00000dddddddddddddddddddddddddddddddddddddddd717dddddddddddddddddddd99822c28111619977777dddddddddddddddddddddddddddeeee2222dd000
00000ddddddddddddddddddddddddddddddddddddd7777799ddddddddddddddddddddd8222281111ddd67776ddddddddddddddddddddddddddd2ee22e22dd000
00000ddddddddddddddddddddddddddddddddddddd67776ddddddddddddddddddddddd82222aaadddddd766ddddddddddddddddddddddddddddd2eeee22dd000
00000dddddddddddddddddddddddddddddddddddddd667dddddddddddddddddddddddd18888addddddd1716dddddddddddddddddddddddddddd11122122d1101
00000dddddddddddddddddddddddddddddddddddddd6171dddddddddddddddddddddd118118ddddddd111161dddddddddddddddddddddddddd11112111ddd000
00000ddddddddddddddddddddddddddddddddddddd161111dddddddddddddddddddddd181111ddddddd1111dddddddddddddddddddddddddddd1111111d1d111
00000dddddddddddddddddddddddddddddddddddddd1111dddddddddddddddddddddddd1111dddddddddddddddddddddddddddddddddddddddddddddddddd000
00000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd000
00000ddddddddddddddddddddddddddddddddddddddddddddddddddd7dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd000
00000dddddddddddddddddddddddddddddddddddddddddddddddddd717ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd000
00000ddddddddddddddddddddddddddddddddddddddddddddddd7777799dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd000
00000ddddddddddddddddddddddddddddddddddddddddddddddd67776dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd000
00000dddddddddddddddddddddddddddddddddddddddddddddddd667ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd000
00000dddddddddddddddddddddddddddddddddddddddddddddddd6171dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd000
00000ddddddddddddddddddddddddddddddddddddddddddddddd161111ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd000
00000dddddddddddddddddddddddddddddddddddddddddddddddd1111dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd000
00000ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd7dddddddddddddddddddddddddddddddd000
00000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd717ddddddddddddddddddddddddddddddd000
00000ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd9977777dddddddddddddddddddddddddddd000
00000ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd67776dddddddddddddddddddddddddddd000
00000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd766ddddddddddddddddddddddddddddd000
00000ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd1716ddddddddddddddddddddddddddddd000
00000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd111161dddddddddddddddddddddddddddd000
00000ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd1111ddddddddddddddddddddddddddddd000
00000ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd7dddddddddddddddddddddddddddddddddddddddddddddddddd000
00000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd717ddddddddddddddddddddddddddddddddddddddddddddddddd000
00000ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd7777799dddddddddddddddddddddddddddddddddddddddddddddddd000
00000ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd67776dddddddddddddddddddddddddddddddddddddddddddddddddd000
00000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd667ddddddddddddddddddddddddddddddddddddddddddddddddddd000
00000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd6171dddddddddddddddddddddddddddddddddddddddddddddddddd000
00000ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd161111ddddddddddddddddddddddddddddddddddddddddddddddddd000
00000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd1111dddddddddddddddddddddddddddddddddddddddddddddddddd000
00000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd717ddddddddddddddddddddddddddddddddddddddddddddddddddd000
00000ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd7777799dddddddddddddddddddddddddddddddddddddddddddddddddd000
00000ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd67776dddddddddddddddddddddddddddddddddddddddddddddddddddd000
00000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd667ddddddddddddddddddddddddddddddddddddddddddddddddddddd000
00000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd6171dddddddddddddddddddddddddddddddddddddddddddddddddddd000
00000ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd161111ddddddddddddddddddddddddddddddddddddddddddddddddddd000
00000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd1111dddddddddddddddddddddddddddddddddddddddddddddddddddd000
00000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd000
00000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd000
00000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd000
00000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd000
00000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd000
00000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd000
00000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd000
00000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd000
00000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd000
00000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd000
00000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd000
00000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd000
00000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

__map__
0808080808080808080808080808080800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0808080808080808080808080808080800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0808080808080808080808080808080800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0808080808080808080808080808080800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0909090909090909090909090909090900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0909090909090909090909090909090900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0909090909090909090909090909090900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0909090909090909090909090909090900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0909090909090909090909090909090900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0909090909090909090909090909090900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0909090909090909090909090909090900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0909090909090909090909090909090900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0909090909090909090909090909090900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
0002000000000090300000000000000000b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200001062018630066300361000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00030000083400a7400a7200a74000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0110000018350183501c3501c2501c2500c2500c250102501025013250132521325217250172500c2500c2500c25010250102500c2520c2501025010250102500c2500c250102501025013250132501325417253
0110000018350183501535015250152500c2500c25010250102501325010252102520c2500c250102500c2500c250102501325013252152501025010250102501025010250102501025013250132501325417253
011000001c1341c1301813018135181001c1241c1201c1201c1250000023124231212312123125000002612426124261212612126125000001f1241f1202d1212d1202d124000001c1241c125281041c1241c125
000300000015002150021300211000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0003000000000182201f1301f50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00030000000000a230182501f50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200002b5502c5502d5503225039250000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000b4200b4300b4500f4300f4500d4501743000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200002035020350203500e3500e3500e3500e35000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0002000000000151501715018150191501b1501b15000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200000000006750067600676006760097700c07000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0002000000000041500813005050050300a1500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00020000000001d430260501765000000290500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200000e01017030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00030000120301b0401e05019050130601f07023070081600a1700b1700b170000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 05424344
00 05424344


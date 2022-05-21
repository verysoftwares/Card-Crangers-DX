-- title:  game title
-- author: game developer
-- desc:   short description
-- script: lua


t=0
c={id="Player",state="card",hp=12,maxhp=12}
c.x=96
c.y=24
c.sprite=5
turn=c

cards={"Attack","Defend","Spell","Item"}

top=""

allenemies={"Rocopter","Cactic","Bumbler"}

function renemy(place)
		local out = {}
		local e = allenemies[math.random(#allenemies)]
		out.id=e
		if out.id=="Rocopter" then out.sprite=76; out.hp=12; out.maxhp=12 end
		if out.id=="Cactic" then out.sprite=140; out.hp=16; out.maxhp=16 end
		if out.id=="Bumbler" then out.sprite=204; out.hp=10; out.maxhp=10 end
		out.y=40
		if place==1 then out.x=80-40+20 end
		if place==2 then out.x=80+20 end
		if place==3 then out.x=80+40+20 end
		if place==4 then out.x=80 end
		if place==5 then out.x=80+40 end
		if place==6 then out.x=80-40 end
		if place==7 then out.x=80 end
		if place==8 then out.x=80+40 end
		if place==9 then out.x=80+40+40 end
		return out		 
end

enemies={renemy(4),renemy(5)}

function TIC()

	--if btn(0) and c.y>0 then c.y=c.y-1 end
	--if btn(1) and c.y<136-16 then c.y=c.y+1 end
	--if btn(2) and c.x>0 then c.x=c.x-1 end
	--if btn(3) and c.x<240-9 then c.x=c.x+1 end

	local mx,my,left=mouse()
	c.x=mx; c.y=my

	if btn(4) or left then c.sprite=37 else c.sprite=5 end
	
	bg()
	
	if turn==c then
			if not c.lose then
					cursorctrl()
			end
	else
			if turn.state=="hit" then
					turn.anim=turn.anim-1
					if turn.anim==0 then

							if turn.hit and turn.hit.hp<=0 then 
									c.lose=true
									top="Game over..." 
									turn.state=nil
									return
							end

							nextturn(); return
					end
			end
			if turn.state=="card" then
					if c.defending then
							top=turn.id.." was blocked."
							sfx(2,12*2,80)
							turn.state="hit"
							turn.anim=100
							turn.hit=nil
					else
							top=turn.id.." hits you!"
							sfx(1,12*2,80)
							turn.state="hit"
							turn.anim=100
							turn.hit=c
							turn.hit.hp=turn.hit.hp-1
					end
			end
			
			for i,e in ipairs(enemies) do
					spr(e.sprite-t%60//50*4,e.x,e.y,0,1,0,0,4,4)
			end
			for i,e in ipairs(enemies) do	
			print(string.format("%d/%d",e.hp,e.maxhp),e.x+4,e.y+32+2,1,false,1,true)
			end
	end
	
	local w= print(top,0,1,15)
	print(top,240/2-w/2,1,1)

	print(string.format("%d/%d",c.hp,c.maxhp),0,136-32-8+2)
	spr(c.sprite,c.x,c.y,4,1,0,0,2,2)
	
	t=t+1
end
encounter=1
function nextturn()
		if turn==c then
				turn=enemies[1]
				if #enemies==0 then
						encounter=encounter+1
						turn=c
						if encounter==2 then
								enemies={renemy(1),renemy(2),renemy(3)}
						else
						  enemies={renemy(6),renemy(7),renemy(8),renemy(9)}
						end
						turn.state="card"
						return
				end
		else
				local j
				for i,v in ipairs(enemies) do
						if v==turn then j=i; break end
				end
				if j+1>#enemies then turn=c
				else turn=enemies[j+1] end
		end
		turn.state="card"
		for i,e in ipairs(enemies) do
				spr(e.sprite-t%60//50*4,e.x,e.y,0,1,0,0,4,4)
		end
		for i,e in ipairs(enemies) do	
		print(string.format("%d/%d",e.hp,e.maxhp),e.x+4,e.y+32+2,1,false,1,true)
		end
end

allcards={"Attack","Defend","Spell","Item"}

function rcard()
		return allcards[math.random( #allcards )]
end

function cursorctrl()
	local _,_,left=mouse()

	if c.state=="card" then
			top = "Pick 1, sacrifice 2."
			if not deckcards then deckcards={rcard(),rcard(),rcard()} end

			c.defending = false
	
			for i,v in ipairs(deckcards) do
					if coll(c.x,c.y,1,1, 80+(i-1)*27,40,27,32) then
							rectb(80+(i-1)*27,40,27,32,t%16)
							print(v,80+(i-1)*27+2,40+14+8,t%16,false,1,true)
							if v=="Attack" then spr(33,80+(i-1)*27+5,40+4,0,1,0,0,2,2) end
							if v=="Defend" then spr(35,80+(i-1)*27+5,40+4,0,1,0,0,2,2) end
       if v=="Spell" then spr(65,80+(i-1)*27+5,40+4,0,1,0,0,2,2) end
							if v=="Item" then spr(67,80+(i-1)*27+5,40+4,0,1,0,0,2,2) end

							if btn(4) or left then
									table.insert(cards,v)
									c.state="idle"
									deckcards=nil
									sfx(4,12*3+5,12)
									return
							end
							
					else
							rectb(80+(i-1)*27,40,27,32,1)
							print(v,80+(i-1)*27+2,40+14+8,1,false,1,true)
							if v=="Attack" then spr(33,80+(i-1)*27+5,40+4,0,1,0,0,2,2) end
							if v=="Defend" then spr(35,80+(i-1)*27+5,40+4,0,1,0,0,2,2) end
       if v=="Spell" then spr(65,80+(i-1)*27+5,40+4,0,1,0,0,2,2) end
							if v=="Item" then spr(67,80+(i-1)*27+5,40+4,0,1,0,0,2,2) end
					end
			end

			for i,v in ipairs(cards) do
					if coll(c.x,c.y,1,1, (i-1)*27,136-32,27,32) then
							--hover
								
							rectb((i-1)*27,136-32,27,32,t%16)
							print(v,(i-1)*27+2,136-32+14+8,t%16,false,1,true)
					else
							rectb((i-1)*27,136-32,27,32,1)
							print(v,(i-1)*27+2,136-32+14+8,1,false,1,true)
					end
					if v=="Attack" then spr(33,(i-1)*27+5,136-32+4,0,1,0,0,2,2) end
					if v=="Defend" then spr(35,(i-1)*27+5,136-32+4,0,1,0,0,2,2) end
					if v=="Spell" then spr(65,(i-1)*27+5,136-32+4,0,1,0,0,2,2) end
					if v=="Item" then spr(67,(i-1)*27+5,136-32+4,0,1,0,0,2,2) end
			end
	end
	if c.state=="hit" then	
			for i,e in ipairs(enemies) do
					if c.hit==e or c.hit==enemies then
							if t%12<6 then 	
									spr(e.sprite-t%60//50*4,e.x,e.y,0,1,0,0,4,4)
							end
					else
							spr(e.sprite-t%60//50*4,e.x,e.y,0,1,0,0,4,4)
					end
			end
			c.anim=c.anim-1
			if c.anim==0 then 
			for i=#enemies,1,-1 do
					if enemies[i].hp<=0 then table.remove(enemies,i) end
			end
			c.state="idle"; nextturn(); return 
			end
	else
			if c.state~="card" then
					for i,e in ipairs(enemies) do
							spr(e.sprite-t%60//50*4,e.x,e.y,0,1,0,0,4,4)
					end
					for i,e in ipairs(enemies) do	
					print(string.format("%d/%d",e.hp,e.maxhp),e.x+4,e.y+32+2,1,false,1,true)
					end
			end
	end

	
	if c.state~="idle" and c.state~="hit" and c.state~="card" then
			if btn(5) then c.state="idle" end
	end
	if c.state=="Spell" then
			top="Hit all enemies."
			c.state="hit"
			c.hit=enemies
			for i,e in ipairs(enemies) do
					e.hp=e.hp-1
			end
			for i=#enemies,1,-1 do
					if enemies[i].hp<=0 then table.remove(enemies,i) end
			end
			c.anim=100
			sfx(0,12*4,80)
			table.remove(cards,c.cardno)
	end
	if c.state=="Defend" then
			top="Defending this turn."
			c.state="hit"
			c.hit=nil
			c.anim=100
			table.remove(cards,c.cardno)
			c.defending = true
	end
	if c.state=="Attack" then
			top = "Attack whom?"
			for i,e in ipairs(enemies) do
					if coll(c.x,c.y,1,1, e.x,e.y,32,32) then
							--hover
							rect(c.x+9,c.y,string.len(e.id)*4,7,1)
							print(e.id,c.x+9+1,c.y+1,15,false,1,true)
							if btn(4) or left then
									top = ""
									sfx(3,12*3+5,80)
									c.state="hit"
									c.anim=60
									c.hit=e
									c.hit.hp=c.hit.hp-2
									table.remove(cards,c.cardno)
							end
					end
			end
	end
	if c.state=="Item" then
			top="6 HP restored."
			c.hp=c.hp+6
			if c.hp>c.maxhp then c.hp=c.maxhp end
			c.state="hit"
			c.hit=nil
			c.anim=100
			table.remove(cards,c.cardno)
	end
	if c.state=="idle" then
			top="Select an action."
			for i,e in ipairs(enemies) do
					if coll(c.x,c.y,1,1, e.x,e.y,32,32) then
							--hover
							rect(c.x+9,c.y,string.len(e.id)*4,7,1)
							print(e.id,c.x+9+1,c.y+1,15,false,1,true)
					end
			end
			for i,v in ipairs(cards) do
					if coll(c.x,c.y,1,1, (i-1)*27,136-32,27,32) then
							--hover
								
							if btn(4) or left then 
									sfx(4,12*3+5,12)
									c.state=v
									c.cardno=i
							end
							
							rectb((i-1)*27,136-32,27,32,t%16)
							print(v,(i-1)*27+2,136-32+14+8,t%16,false,1,true)
							if v=="Attack" then spr(33,(i-1)*27+5,136-32+4,0,1,0,0,2,2) end
							if v=="Defend" then spr(35,(i-1)*27+5,136-32+4,0,1,0,0,2,2) end
							if v=="Spell" then spr(65,(i-1)*27+5,136-32+4,0,1,0,0,2,2) end
							if v=="Item" then spr(67,(i-1)*27+5,136-32+4,0,1,0,0,2,2) end
					else
							rectb((i-1)*27,136-32,27,32,1)
							print(v,(i-1)*27+2,136-32+14+8,1,false,1,true)
							if v=="Attack" then spr(33,(i-1)*27+5,136-32+4,0,1,0,0,2,2) end
							if v=="Defend" then spr(35,(i-1)*27+5,136-32+4,0,1,0,0,2,2) end
							if v=="Spell" then spr(65,(i-1)*27+5,136-32+4,0,1,0,0,2,2) end
							if v=="Item" then spr(67,(i-1)*27+5,136-32+4,0,1,0,0,2,2) end
					end
			end
	end
end

pi=math.pi
function bg()
	bg_t=bg_t or 0
	cls(15)
	rect(0,8,240,8,6+math.floor(((bg_t)*0.15+2)%3)*3)
	rect(0,16,240,8,6+math.floor(((bg_t)*0.15+1)%3)*3)
	rect(0,24,240,8,6+math.floor((bg_t*0.15)%3)*3)
	rect(0,72+24,240,8,6+math.floor(((bg_t)*0.15+2)%3)*3)
	rect(0,72+16,240,8,6+math.floor(((bg_t)*0.15+1)%3)*3)
	rect(0,72+8,240,8,6+math.floor((bg_t*0.15)%3)*3)
	rect(0,24+8,8,72-24,6+math.floor((bg_t*0.15)%3)*3)
	rect(8,24+8,8,72-24,6+math.floor(((bg_t)*0.15+1)%3)*3)
	rect(16,24+8,8,72-24,6+math.floor(((bg_t)*0.15+2)%3)*3)
	rect(240-8-0,24+8,8,72-24,6+math.floor((bg_t*0.15)%3)*3)
	rect(240-8-8,24+8,8,72-24,6+math.floor(((bg_t)*0.15+1)%3)*3)
	rect(240-8-16,24+8,8,72-24,6+math.floor(((bg_t)*0.15+2)%3)*3)
	if c.state=="card" then
	bg_t=bg_t+1
	else bg_t=0 end
end

function coll(x1,y1,w1,h1, x2,y2,w2,h2)
  return x1 < x2+w2 and
         x2 < x1+w1 and
         y1 < y2+h2 and
         y2 < y1+h1
end

-- <TILES>
-- 001:efffffffff222222f8888888f8222222f8fffffff8ff0ffff8ff0ffff8ff0fff
-- 002:fffffeee2222ffee88880fee22280feefff80fff0ff80f0f0ff80f0f0ff80f0f
-- 003:efffffffff222222f8888888f8222222f8fffffff8fffffff8ff0ffff8ff0fff
-- 004:fffffeee2222ffee88880fee22280feefff80ffffff80f0f0ff80f0f0ff80f0f
-- 005:0f0444440ff044440ff044440fff04440fff04440ffff0440ffff0440fffff04
-- 006:4444444444444444444444444444444444444444444444444444444444444444
-- 007:0000000000000000000000000000000c000000c0000000cc000000cc000000cc
-- 008:00cc00000cc0cc00cc000cc0cc0000ccc000000cc000000c0000000c0000000c
-- 012:bbbbbbebbbbbbbbbbbebbbbbbbbbbbbebbbbebbbbbbbbbbbbebbbbbbbbbbbbbe
-- 013:bbbbbbbbbbbbebbbbbbbbbbbbbbbbbbbbebbbbbbbbbbbbebbbbbbbbbbbbbbbbb
-- 014:bbbbbebbbbbbbbbbbbbbbbbbbbebbbbbbbbbbbbbbbbbebbbbbbbbbbbbbbbbbbb
-- 015:bbbbbbbbbebbbbbbbbbbbbbbbbbbbbbebbbbbbbbbbbbbbbbbbbebbbbbbbbbbbb
-- 017:f8fffffff8888888f888f888f8888ffff8888888f2222222ff000fffefffffef
-- 018:fff800ff88880ffef8880fee88880fee88880fee2222ffee000ffeeeffffeeee
-- 019:f8fffffff8888888f888f888f8888ffff8888888f2222222ff000fffefffffef
-- 020:fff800ff88880ffef8880fee88880fee88880fee2222ffee000ffeeeffffeeee
-- 021:0fffff040ffffff00ffffff00fffffff0ff0ff000f00ff0440440ff044440ff0
-- 022:4444444444444444444444440444444444444444444444444444444444444444
-- 023:000000c0000000c000000c00000cc00000cc000000c000000c000000cc00000c
-- 024:0000000c0000000c0000000c00000000000000000000000000000000cc00000c
-- 025:00000000c0000000cc0000000cc0000000cc0000000c0000000cc0000000c000
-- 028:bbbbebbbbbbbbbbbebbbbbbbbbbbbbbbbbbbebbbbbbbbbbbbbbbbbbbbbbbbbeb
-- 029:bbbbbbbbbbbbbebbebbbbbbbbbbbbbbbbbbbbbbbbbbbbbebbbbbbbbbbbbbbbbb
-- 030:bbbbbbbbbcccccccbcccccccbcccccccbcccccccbcccccccbcccccccbccccccb
-- 031:bbbbbbbbccccccccccccccccccccccccccccccccccccccccccccccccbbbbebbb
-- 033:00000000000000000000000000000000000000000000000a000000a000900a00
-- 034:000000000000000000aaaa000a000a00a0000a0000000a000000a000000a0000
-- 035:0000000000000000000a0000000aa000000aaa0a000a0aaa000a00a0000a0000
-- 036:00000000000000000000a000000aa000a0aaa000aaa0a0000a00a0000000a000
-- 037:4444444444400444440ff044440ff044440ff044440ff000400ff0ff000ff0ff
-- 038:444444444444444444444444444444444444444404444444000444440f044444
-- 039:c00000ccc0000cc0c0000c00c000ccc0c00ccc00c00c0c00c0c00c00ccc00c00
-- 040:0000000c0000000c0000000c0000000c0000000c00c0000c00c0000c00c0000c
-- 041:0000c000c0000c00c0000c00c0000c00cc000c00cc000c000c000c00ccccc000
-- 044:bebbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbebbbbbbbbbbbbbbbbbbbbe
-- 045:bbbbebbbbbbbbbbbbbbbbbbbebbbbbbbbbbbebbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 046:bccccccbbccccccbbccccccbbccccccbbccccccbbccccccbbccccccbbccccccb
-- 047:bbbbbbbbbbbbbbbbbebbbbbebbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbebbbb
-- 049:0099a00a000990a0000099000009999a00999099099900090090000000000000
-- 050:00a000000a000000a00000000000000000000000900000000000000000000000
-- 051:000a0090000a0099000aa0090000aa0000000aa0000000aa0000000a00000000
-- 052:0900a0009900a000900aa00000aa00000aa00000aa000000a000000000000000
-- 053:0f0ff0ff0ffff0ff0fffffff0fffffff0fffffff00ffffff4000000044444444
-- 054:0f0444440f044444ff044444ff044444ff044444f00444440044444444444444
-- 055:00000c0000000c0000000c0000000c0000000c0000000c0000000c0000000ccc
-- 056:00c0000c00c000000cc0000c0cc0000c0cc000cc0cc000cc0cc000ccc0c00cc0
-- 057:c0000000c0000000c0000000c0000000c0000000000000000000000000000000
-- 060:bbbbbbbbccccccccccccccccccccccccccccccccccccccccccccccccbbbbbbbe
-- 061:bbbbbbbbccccccccccccccccccccccccccccccccccccccccccccccccbbbbbbbb
-- 062:bccccccbcccccccbcccccccbcccccccbcccccccbcccccccbcccccccbbebbbbbb
-- 063:bbbbebbbebbbbbbebbbbbbbbbbbbbbbbbbbebbbbbbbbbbbbebbbbbbbbbbbbbbb
-- 065:000000000000000000000000000990000009990000009999000099990009999f
-- 066:000000000090000009900000999000009990000099900000f9999999f99f9900
-- 067:0000000000000000000000000000009900000a99000000a0000000a0000000a0
-- 068:0000000000000000000000009900000099a000000a0000000a0000000a000000
-- 073:0000000000000000000000000000000000000000000000000000000c000ccccc
-- 074:00000000000000000000000000000000000000c000000c00ccccc000c77ccc00
-- 076:00000000000000000000000000000000000000000000000000000000000ccccc
-- 077:00000000000000000000000000000000000000000000000000000000cccc0000
-- 078:00000000000000000000000000000000000000c000000c00000c000000c00000
-- 079:000000000000000000000000000000000000000000000000000000000000cccc
-- 081:009999ff0999ffff9999f99f990999ff000999f9000990990009000900000009
-- 082:ffff9000ff999000ff999900fff9990099f99990999099909000000000000000
-- 083:00000a000000aa00000a000000aa000000aa0000000aaaaa0000000000000000
-- 084:00a0000000aa00000000a0000000aa000000aa00aaaaa0000000000000000000
-- 088:000000000000000000000000000000000000000000000000000000770000077c
-- 089:0000cccc00007ccc000077cc0cccccc700ccccc777cccc777c7ccc7ccc777ccc
-- 090:c7ccccc0c7cc77007cc777007ccccc00cccccc00cccccc70ccccc770ccc77c7c
-- 091:0000000000000000000000000000000000000000000000000000000070000000
-- 092:0ccccccc0cccc777000ccccc0000000c0000000000000000000000770000077c
-- 093:ccccc00077cccc00c77777c0ccccc7770cccccc77777cccc7ccccccccccccccc
-- 094:0c000000c0000cccc00ccc77cccc777cc777ccccc7cc0000ccccc700cccccc7c
-- 095:cccc77ccc7777ccc77ccccccccccccc0ccc00000000000000000000070000000
-- 104:0000c7cc000c7ccc0007cc2c007c7cc20077cccc007ccccc00cccccc00cccccc
-- 105:cccc777ccccccc77cccccccc2222ccc2cccccccccccccccccccccccccccccccc
-- 106:c777ccc77ccccccccccc2ccc2222cccccccccccccccccccccccccccccccccccc
-- 107:c700000077000000c770000077700000c7700cc0cc770c7c7c77c7c7c7c7c777
-- 108:0000c7cc000c7ccc0007cc2c007c7cc20077cccc007ccccc00cccccc00cccccc
-- 109:cccccccccccccccccccccccc2222ccc2cccccccccccccccccccccccccccccccc
-- 110:ccccccc7cccccccccccc2ccc2222cccccccccccccccccccccccccccccccccccc
-- 111:c700000077000000c770000077700000c7700cc0cc770c7c7c77c7c7c7c7c777
-- 120:007c22c2007cc2220077c22c000c7ccc0077c7cc00777c7c0007770000077000
-- 121:22222222cccccccccccc77cccccccccccccccccccccccccc77ccccc700000000
-- 122:222c2ccccc222cc7cc22cccccccccc7ccccccc7ccc7cc770777c777000007700
-- 123:7c7c7770c77000007770000077000000c0000000000000000000000000000000
-- 124:007c22c2007cc2220077c22c000c7ccc0077c7cc00777c7c0007770000077000
-- 125:22222222cccccccccccc77cccccccccccccccccccccccccc77ccccc700000000
-- 126:222c2ccccc222cc7cc22cccccccccc7ccccccc7ccc7cc770777c777000007700
-- 127:7c7c7770c77000007770000077000000c0000000000000000000000000000000
-- 137:000000bb00000bbb0000bbbb0000bbbb000bbbbb000bbbbb000bbbbb000bbbbb
-- 138:b0000000bb300000bbb30000bbbb0000bbbb3000bbbb3000bbbb3000bbbb3300
-- 139:0000000000000000000000000000000000bbb00000bbbb0000bbbb000bbbbb00
-- 140:000000000000000000000bb00000bbbb000bbbbb000bbbbb000bbbb3000bbbb3
-- 141:000000bb00000bbb0000bbbb0000bbbb000bbbbb000bbbbb000bbbbb000bbbbb
-- 142:b0000000bb300000bbb30000bbbb0000bbbb3000bbbb3000bbbb3000bbbb3300
-- 152:00000bb00000bbbb000bbbbb000bbbbb000bbbb3000bbbb3000bbbb3000bbbb3
-- 153:00bbbbbb00bbbbbb00bbbbbb00bb2bbb00bb2bbb00bb2bbb00bb2bbb03bbbbbb
-- 154:bbbbb300bbbbb300bbbbb300b2bb3300b2bb3300b2bb330bb2bb33bbbbbb33bb
-- 155:0bbbb3000bbbb3000bbb33000bbb3300bbbb3300bbbb3300bbbb3300bbbb3000
-- 156:000bbbb3000bbbb3000bbbb3000bbbb3000bbbbb000bbbbb0000bbbb0000bbbb
-- 157:00bbbbbb00bbbbbb00bbbbbb00bb2bbb00bb2bbb30bb2bbbb3bb2bbbbbbbbbbb
-- 158:bbbbb300bbbbb300bbbbb300b2bb3300b2bb3300b2bb3300b2bb3300bbbb3300
-- 159:000000000000000000bbb00000bbbb0000bbbb000bbbbb000bbbb3000bbbb300
-- 168:000bbbb3000bbbb3000bbbbb000bbbbb0000bbbb0000bbbb0000bbbb0000bbbb
-- 169:03bbbbbb0bbbbb220bbbbb223bbbbb22bbbbbbbbbbbbbbbbb3bbbbbb3bbbbbbb
-- 170:bbbb3bbbbbbb3bbbbbbbb3bbbbbbb3bbbbbbb3b3bbbbbbb0bbbbbb00bbbbbb00
-- 171:bbb33000bb330000bb330000b300000030000000000000000000000000000000
-- 172:0000bbbb0000bbbb00000bb30000003300000003000000000000000000000000
-- 173:b3bbbbbb3bbbbb223bbbbb223bbbbb223bbbbbbb0bbbbbbb0bbbbbbb0bbbbbbb
-- 174:bbbb3300bbbb3000bbbbb000bbbbb00bbbbbb0bbbbbbbbbbbbbbbbbbbbbbbbbb
-- 175:0bbb33000bbb3300bbbb3300bbbb3300bbbb3300bbbb3000bbb33000bb330000
-- 184:00000bb300000033000000030000000000000000000000000000000000000000
-- 185:3bbbbbbb3bbbbbbb3bbbbbbb0bbbbbbb0bbbbbbb0bbbbbbb0bbbbbbb0bbbbbbb
-- 186:bbbbbb00bbbb3000bbbb3000bbbb3000bbb30000bb330000bb330000bb330000
-- 189:0bbbbbbb0bbbbbbb0bbbbbbb0bbbbbbb0bbbbbbb0bbbbbbb0bbbbbbb0bbbbbbb
-- 190:bbb3bbbbbbb3bbbbbbbb3bb3bbbb3bb0bbb30000bb330000bb330000bb330000
-- 191:bb330000b3000000300000000000000000000000000000000000000000000000
-- 200:eeeee000e000eee0000000ee0000000e000000ee00000ee30000ee33000ee333
-- 201:00000eee0000ee000000e0000000e000eeeee00033333ee0333333ee3333333e
-- 202:eee00000000ea000000aaaa000aaa3a00aaa333a0a3a3a330a33a3330a3a3a33
-- 203:0000000000000000000000000000000000000000a0000000a0aaaaa03aa333aa
-- 204:eeeee000e000eee0000000ee0000000e000000ee00000ee30000ee33000ee633
-- 205:00000eee0000ee000000e0000000e000eeeee00033333ee0333333ee3336633e
-- 206:eee0000a000e0aaa0000aa33000aa333000a3333000aa3a3000a3a33000aa3a3
-- 207:a0000000a00aaaa03aaa333a3a33333aaa33333aa3a3a33aaa3a333aa3a3a33a
-- 216:000e6333000e663300093663000e33660009e333000093330000933300000933
-- 217:333363333336633333663333366333333333333e3333333e33333e9e3339e9e9
-- 218:eaa3a33ae0aa3a3ae0aaa33ae00a33aaeeee33aaeeeeeea3ee333eaae33333ee
-- 219:aa3a333aa3a3a3333a3a333aa3a333aa3333aaa0aaaaa000a000000000000000
-- 220:000e6663000e666600093666000e33660009e333000093330000933300000933
-- 221:336663333666633336663333366333333333333e3333333e33333e9e3339e9e9
-- 222:e00a3a3ae00aa3aae000aa3ae000a33aeeee333aeeeeeea3ee333eaae33333ee
-- 223:3a3a333aa3a333a03a333aa03333aa0033aa0000aaa00000a000000000000000
-- 232:0000009300000009000000000000000000000000000000090000009900000990
-- 233:39909e9e900099e3000099930009993309909933900009330000993300099933
-- 234:3333333e333333333333333e333333ee3333ee3e333333ee333e39e933939e9e
-- 235:e0000000ee000000ee000000eee00000eeee0000eeee0000eeeee000eeeee000
-- 236:0000009300000009000000000000000000000000000000090000009900000990
-- 237:39909e9e900099e3000099930009993309909933900009330000993300099933
-- 238:3333333e333333333333333e333333ee3333ee3e333333ee333e39e933939e9e
-- 239:e0000000ee000000ee000000eee00000eeee0000eeee0000eeeee000eeeee000
-- 248:0000090000009000000090090000000000000000000000000000000000000000
-- 249:0099009399900099900000090000009900009990009900000900099900009900
-- 250:3399e9e939399e9e999999e99999999300999999999000990000000000000000
-- 251:e3e3ee003e333e00e3333ee0e33333e0333333e0999e9e000000000000000000
-- 252:0000090000009000000090090000000000000000000000000000000000000000
-- 253:0099009399900099900000090000009900009990009900000900099900009900
-- 254:3399e9e939399e9e999999e99999999300999999999000990000000000000000
-- 255:e3e3ee003e333e00e3333ee0e33333e0333333e0999e9e000000000000000000
-- </TILES>

-- <WAVES>
-- 000:00000000ffffffff00000000ffffffff
-- 001:0123456789abcdeffedcba9876543210
-- 002:0123456789abcdef0123456789abcdef
-- 003:790b517a8ed8525a4ccb9cdc37bf1642
-- </WAVES>

-- <SFX>
-- 000:010001000200020002000200000000000000010002000100020002000100000001000100010001000100010001000100020002000200020002000200300000000000
-- 001:000000000000000000000000000000000000010001000100010001000100010001000000000000000000000000000000000000000000020002000200100000000000
-- 002:020002000200020002000200020002000200020002000200020002000200020002000200020002000100010001000100010001000000000000000200100000000000
-- 003:020002000200020002000200020002000200020001000200020002000200020000000200020002000200020001000100010001000100020001000100300000000000
-- 004:000001000200000001000200000001000200000001000200000001000200000001000200010001000100010001000100010000000100010001000100305000000000
-- 005:030003000300030003000300030003000300030003000300030003000300030003000300030003000300030003000300030003000300030003000300000000000000
-- </SFX>

-- <PATTERNS>
-- 003:4ff108000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 004:4ff106000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 005:4ff106000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 006:4ff106000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- </PATTERNS>

-- <TRACKS>
-- 000:000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- </TRACKS>

-- <PALETTE>
-- 000:140c1c44243430346d4e4a4e854c30346524d04648757161597dced27d2c8595a16daa2cd2aa996dc2cadad45edeeed6
-- </PALETTE>


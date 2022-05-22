-- title:  game title
-- author: game developer
-- desc:   short description
-- script: lua

sub=string.sub
ins=table.insert
rem=table.remove

t=0
c={id="Player",state="card",hp=18,maxhp=18,honey=0}
c.x=96
c.y=24
c.sprite=5
turn=c

cards={"Attack","Defend","Spell","Item",'Honey','Spike','Sleep','Clone'}

top=""

allenemies={"Rocopter","Cactic","Bumbler",'Yggdra'}

drafted=0
defeated=0

function renemy(place)
		local out = {}
		local e = allenemies[math.random(#allenemies)]
		out.id=e
		if out.id=="Rocopter" then out.sprite=76; out.hp=10-3; out.maxhp=10-3; out.atk=1 end
		if out.id=="Cactic" then out.sprite=140; out.hp=16-3; out.maxhp=16-3; out.atk=2 end
		if out.id=="Bumbler" then out.sprite=204; out.hp=8; out.maxhp=8; out.atk=3 end
		if out.id=="Yggdra" then out.sprite=261; out.hp=16; out.maxhp=16; out.atk=0 end
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

music(0)

function TIC()

	--if btn(0) and c.y>0 then c.y=c.y-1 end
	--if btn(1) and c.y<136-16 then c.y=c.y+1 end
	--if btn(2) and c.x>0 then c.x=c.x-1 end
	--if btn(3) and c.x<240-9 then c.x=c.x+1 end

	poke(0x3FFB,0) -- hide system cursor

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

							if not turn.pending then nextturn(); return
							else 
									if enemycard(turn.id)=='Honey' then
											c.honey=c.honey+1
											c.honeymem=c.honeymem or {}
											local ei
											for i,e in ipairs(enemies) do if e==turn then ei=i; break end end
											for j,d in ipairs(c.honeymem) do if d[1]==ei then d[2]=d[2]+1; goto skip end end
											ins(c.honeymem,{ei,1})
											::skip::
											top=string.format('Your attacks are weakened by %d!',c.honey)
											turn.anim=140		
											turn.pending=nil
									else
											turn.pending=nil
											nextturn()
									end
							end
					end
			elseif turn.state=="card" then
					if c.defending then
							if #enemies>1 then
							top='Enemies were blocked.'
							else
							top=string.format('%s was blocked.',enemies[1].id)
							end
							sfx(2,12*2,80,2)
							turn.state='hit'
							turn.anim=100
							turn.hit=nil
					else
							local dmg=0
							for i,e in ipairs(enemies) do
									if not e.pending then
									dmg=dmg+e.atk
									end
							end
							if #enemies>1 then
							top=string.format('Enemies hit you for %d HP!',dmg)
							else
							top=string.format('%s hit you for %d HP!',enemies[1].id,dmg)
							end
							sfx(1,12*2,80,2)
							turn.state="hit"
							turn.anim=100
							turn.hit=c
							turn.hit.hp=turn.hit.hp-dmg
					end
					--[[
					if c.defending then
							top=turn.id.." was blocked."
							sfx(2,12*2,80,2)
							turn.state="hit"
							turn.anim=100
							turn.hit=nil
					else
							top=turn.id.." hits you!"
							sfx(1,12*2,80,2)
							turn.state="hit"
							turn.anim=100
							turn.hit=c
							turn.hit.hp=turn.hit.hp-1
					end
					]]
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

	if c.state~='card' and not c.lose then
	local w= print(string.format("HP: %d/%d",c.hp,c.maxhp),0,-6)
	print(string.format("HP: %d/%d",c.hp,c.maxhp),240/2-w/2,136-32-8+2-64-32+8)

	local w= print(string.format("Cards drafted: %d",drafted),0,-6)
	print(string.format("Cards drafted: %d",drafted),240/2-w/2,136-32-8+2-64-32+8+8,12)

	local w= print(string.format("Enemies defeated: %d",defeated),0,-6)
	print(string.format("Enemies defeated: %d",defeated),240/2-w/2,136-32-8+2-64-32+8+8+8,9)
	end
	if c.lose then
	local w= print('R to reset.',0,-6)
	print(string.format("R to reset.",c.hp,c.maxhp),240/2-w/2,136-32-8+2-64-32+8)
	if keyp(18) then reset() end
	end

	spr(c.sprite,c.x,c.y,4,1,0,0,2,2)
	
	t=t+1
end

function enemycard(id)
		if id=='Rocopter' then return 'Sleep' end
		if id=='Cactic' then return 'Spike' end
		if id=='Bumbler' then return 'Honey' end
		if id=='Yggdra' then return 'Clone' end
end

encounter=1
function nextturn()
		if turn==c then
				--turn=enemies[1]
				turn=enemies
				for i,e in ipairs(enemies) do
						if math.random(1,5)==1 then
								e.pending=true
						end
				end
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
				turn.state="card"
		else
				--[[local j
				for i,v in ipairs(enemies) do
						if v==turn then j=i; break end
				end
				if j+1>#enemies then 
				turn=c
				if c.defending then c.defending=c.defending-1; if c.defending<=0 then c.defending=nil end end
				c.combo=nil
				else turn=enemies[j+1] end
				]]
				local pending=nil
				for i,e in ipairs(enemies) do
						if e.pending then pending=e; break end
				end
				if not pending then
						turn=c
						if turn.defending then turn.defending=turn.defending-1; if turn.defending<=0 then turn.defending=nil end end
						turn.combo=nil
						turn.state='card'
				else
						turn=pending
						turn.state='hit'
						turn.anim=140
						top=string.format('%s uses card: %s!',turn.id,enemycard(turn.id))
				end
		end
		for i,e in ipairs(enemies) do
				spr(e.sprite-t%60//50*4,e.x,e.y,0,1,0,0,4,4)
		end
		for i,e in ipairs(enemies) do	
		print(string.format("%d/%d",e.hp,e.maxhp),e.x+4,e.y+32+2,1,false,1,true)
		end
end

allcards={"Attack","Defend","Spell","Item",'Plus 1','Plus 2','Plus 3','Draft'}

function rcard()
		return allcards[math.random( #allcards )]
end

function clearcards()
		if c.combo then 
		local cno_rem=false
		for j=#c.combo,1,-1 do
				local w=c.combo[j]; 
				if (not cno_rem) and c.cardno>w[2] then
				rem(cards,c.cardno)
				cno_rem=true
				end
				rem(cards,w[2])
				if (not cno_rem) and c.cardno<w[2] and ((not c.combo[j-1]) or (c.combo[j-1] and c.cardno>c.combo[j-1][2])) then
				rem(cards,c.cardno)
				cno_rem=true
				end
		end
		else
		table.remove(cards,c.cardno)
		end
end

function combovalue()
		local out=0
		if not c.combo then return out end
		for j,w in ipairs(c.combo) do
				out=out+tonumber(sub(w[1],6,6))
		end
		return out
end

cam={i=1}
function cursorctrl()
	old_left=left
	_,_,left=mouse()
	if not leftclick then
			leftclick=left and not old_left
	else
			leftclick=false
	end

	if c.state~='card' and c.state~='hit' and c.state~='waitsfx' then
			if coll(c.x,c.y,1,1, 240-27,136-32,27,32) then
					rectb(240-27,136-32,27,32,t%16)
					print('Skip',240-27+2,136-32+14+8,t%16,false,1,true)
					spr(161,240-27+5,136-32+4,0,1,0,0,2,2)
					if btn(4) or left then
							nextturn()
					end
			else
					rectb(240-27,136-32,27,32,1)
					print('Skip',240-27+2,136-32+14+8,1,false,1,true)
					spr(161,240-27+5,136-32+4,0,1,0,0,2,2)
			end
	end

	if c.state=='waitsfx' then
			c.draftt=c.draftt-1
			if c.draftt<=0 then
					c.draftt=nil
					nextturn()
			end
	end

	if c.state=="card" then
			top = "Pick 1, sacrifice 2."
			if not deckcards then deckcards={rcard(),rcard(),rcard()} end

			for i,v in ipairs(deckcards) do
					if coll(c.x,c.y,1,1, 80+(i-1)*27,40,27,32) then
							rectb(80+(i-1)*27,40,27,32,t%16)
							print(v,80+(i-1)*27+2,40+14+8,t%16,false,1,true)
							if v=="Attack" then spr(33,80+(i-1)*27+5,40+4,0,1,0,0,2,2) end
							if v=="Defend" then spr(35,80+(i-1)*27+5,40+4,0,1,0,0,2,2) end
       if v=="Spell" then spr(65,80+(i-1)*27+5,40+4,0,1,0,0,2,2) end
							if v=="Item" then spr(67,80+(i-1)*27+5,40+4,0,1,0,0,2,2) end
							if v=="Plus 1" then spr(97,80+(i-1)*27+5,40+4,0,1,0,0,2,2) end
							if v=="Plus 2" then spr(99,80+(i-1)*27+5,40+4,0,1,0,0,2,2) end
							if v=="Plus 3" then spr(129,80+(i-1)*27+5,40+4,0,1,0,0,2,2) end
							if v=="Draft" then spr(131,80+(i-1)*27+5,40+4,0,1,0,0,2,2) end
							if v=="Honey" then spr(163,80+(i-1)*27+5,40+4,0,1,0,0,2,2) end
							if v=="Spike" then spr(193,80+(i-1)*27+5,40+4,0,1,0,0,2,2) end
							if v=="Sleep" then spr(195,80+(i-1)*27+5,40+4,0,1,0,0,2,2) end
							if v=="Clone" then spr(225,80+(i-1)*27+5,40+4,0,1,0,0,2,2) end

							if btnp(4) or leftclick then
									table.insert(cards,v)
									drafted=drafted+1
									if c.draft then c.draft=c.draft-1; if c.draft<=0 then c.draft=nil; c.state='waitsfx'; c.draftt=30 end
									elseif not c.draft then c.state="idle" end
									deckcards=nil
									c.combo=nil
									sfx(4,12*3+5,12,2)
									return
							end
							
					else
							rectb(80+(i-1)*27,40,27,32,1)
							print(v,80+(i-1)*27+2,40+14+8,1,false,1,true)
							if v=="Attack" then spr(33,80+(i-1)*27+5,40+4,0,1,0,0,2,2) end
							if v=="Defend" then spr(35,80+(i-1)*27+5,40+4,0,1,0,0,2,2) end
       if v=="Spell" then spr(65,80+(i-1)*27+5,40+4,0,1,0,0,2,2) end
							if v=="Item" then spr(67,80+(i-1)*27+5,40+4,0,1,0,0,2,2) end
							if v=="Plus 1" then spr(97,80+(i-1)*27+5,40+4,0,1,0,0,2,2) end
							if v=="Plus 2" then spr(99,80+(i-1)*27+5,40+4,0,1,0,0,2,2) end
							if v=="Plus 3" then spr(129,80+(i-1)*27+5,40+4,0,1,0,0,2,2) end
							if v=="Draft" then spr(131,80+(i-1)*27+5,40+4,0,1,0,0,2,2) end
							if v=="Honey" then spr(163,80+(i-1)*27+5,40+4,0,1,0,0,2,2) end
							if v=="Spike" then spr(193,80+(i-1)*27+5,40+4,0,1,0,0,2,2) end
							if v=="Sleep" then spr(195,80+(i-1)*27+5,40+4,0,1,0,0,2,2) end
							if v=="Clone" then spr(225,80+(i-1)*27+5,40+4,0,1,0,0,2,2) end
					end
			end

			for i=cam.i,cam.i+6 do
					local v=cards[i]
					if not v then break end
					local x=(i-cam.i)*27+12
					if coll(c.x,c.y,1,1, x,136-32,27,32) then
							--hover
								
							rectb(x,136-32,27,32,t%16)
							print(v,x+2,136-32+14+8,t%16,false,1,true)
					else
							rectb(x,136-32,27,32,1)
							print(v,x+2,136-32+14+8,1,false,1,true)
					end
					if v=="Attack" then spr(33,x+5,136-32+4,0,1,0,0,2,2) end
					if v=="Defend" then spr(35,x+5,136-32+4,0,1,0,0,2,2) end
					if v=="Spell" then spr(65,x+5,136-32+4,0,1,0,0,2,2) end
					if v=="Item" then spr(67,x+5,136-32+4,0,1,0,0,2,2) end
					if v=="Plus 1" then spr(97,x+5,136-32+4,0,1,0,0,2,2) end
					if v=="Plus 2" then spr(99,x+5,136-32+4,0,1,0,0,2,2) end
					if v=="Plus 3" then spr(129,x+5,136-32+4,0,1,0,0,2,2) end
					if v=="Draft" then spr(131,x+5,136-32+4,0,1,0,0,2,2) end
					if v=="Honey" then spr(163,x+5,136-32+4,0,1,0,0,2,2) end
					if v=="Spike" then spr(193,x+5,136-32+4,0,1,0,0,2,2) end
					if v=="Sleep" then spr(195,x+5,136-32+4,0,1,0,0,2,2) end
					if v=="Clone" then spr(225,x+5,136-32+4,0,1,0,0,2,2) end
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
			local honeyrem=false
			for i=#enemies,1,-1 do
					local e=enemies[i]
					if e.hp<=0 then table.remove(enemies,i); defeated=defeated+1 
					if c.honeymem then for j,d in ipairs(c.honeymem) do
							if d[1]==i then c.honey=c.honey-d[2]; top=string.format('Player is free from %s\'s Honey!',e.id); c.anim=140; c.hit=nil; honeyrem=true break end
					end end
					end
			end
			if not honeyrem then
			c.state="idle"; nextturn(); return
			end
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
			if c.combo then top=string.format('Hit all enemies for %d+%d HP.',1-c.honey,combovalue())
			else top=string.format("Hit all enemies for %d HP.",1-c.honey) end
			c.state="hit"
			c.hit=enemies
			for i,e in ipairs(enemies) do
					e.hp=e.hp-(1+combovalue()-c.honey)
					if e.hp>e.maxhp then e.hp=e.maxhp end 
			end
			c.anim=100
			sfx(0,12*4,80,2)
			clearcards()
	end
	if c.state=="Defend" then
			c.defending=c.defending or 0
			if c.defending+1+combovalue()==1 then
			top="Defending for 1 turn."
			else
			top=string.format("Defending for %d+%d turns.",c.defending+1,combovalue())
			end
			c.state="hit"
			c.hit=nil
			c.anim=100
			clearcards()
			c.defending = c.defending+1+combovalue()
	end
	if c.state=="Attack" then
			top = "Attack whom?"
			if #enemies==1 then
					local e=enemies[1]
					if c.combo then top=string.format('Hit %s for %d+%d HP.',e.id,2-c.honey,combovalue()*2)
					else top=string.format("Hit %s for %d HP.",e.id,2-c.honey) end
					sfx(3,12*3+5,80,2)
					c.state="hit"
					c.anim=90
					c.hit=enemies[1]
					c.hit.hp=c.hit.hp-(2+combovalue()*2-c.honey)
					if c.hit.hp>c.hit.maxhp then c.hit.hp=c.hit.maxhp end 
					clearcards()
			else
			for i,e in ipairs(enemies) do
					if coll(c.x,c.y,1,1, e.x,e.y,32,32) then
							--hover
							rect(c.x+9,c.y,string.len(e.id)*4,7,1)
							print(e.id,c.x+9+1,c.y+1,15,false,1,true)
							if btn(4) or left then
									if c.combo then top=string.format('Hit %s for %d+%d HP.',e.id,2-c.honey,combovalue()*2)
									else top=string.format("Hit %s for %d HP.",e.id,2-c.honey) end
									sfx(3,12*3+5,80,2)
									c.state="hit"
									c.anim=90
									c.hit=e
									c.hit.hp=c.hit.hp-(2+combovalue()*2-c.honey)
									if c.hit.hp>c.hit.maxhp then c.hit.hp=c.hit.maxhp end 
									clearcards()
							end
					end
			end
			end
	end
	if c.state=="Item" then
			if c.combo then top=string.format('%d+%d HP restored.',3,combovalue()*3)
			else top="3 HP restored." end
			c.hp=c.hp+(3+combovalue()*3)
			if c.hp>c.maxhp then c.hp=c.maxhp end
			c.state="hit"
			c.hit=nil
			c.anim=100
			clearcards()
	end
	if sub(c.state,1,4)=='Plus' then
			top='Select a combo card.'
	end
	if c.state=="idle" then
			top="Select an action."
	end
	if c.state=='Draft' then
			c.draft=1+combovalue()
			clearcards()
			c.state='card'
	end
	if (#cards>7 or cam.i>1) and c.state~='Attack' and c.state~='hit' and c.state~='waitsfx' then
			rect(0,136-32,12,32,1)
			rect(240-27-12,136-32,12,32,1)
			if cam.i>1 then spr(69,2,136-32+12,0) end
			if cam.i<#cards-6 then spr(70,240-27-12+2,136-32+12,0) end
			if btnp(2) or (leftclick and coll(c.x,c.y,1,1, 0,136-32,12,32)) then cam.i=cam.i-1; if cam.i<1 then cam.i=1 end end
			if btnp(3) or (leftclick and coll(c.x,c.y,1,1, 240-27-12,136-32,12,32)) then cam.i=cam.i+1; if cam.i>#cards-6 then cam.i=#cards-6 end end
	end
	if c.state=='idle' or sub(c.state,1,4)=='Plus' then
			for i,e in ipairs(enemies) do
					if coll(c.x,c.y,1,1, e.x,e.y,32,32) then
							--hover
							local w=print(e.id,0,-6,15,false,1,true)
							rect(c.x+9,c.y,w+1,7,1)
							print(e.id,c.x+9+1,c.y+1,15,false,1,true)
					end
			end
			for i=cam.i,cam.i+6 do
					local v=cards[i]
					if not v then break end
					local x=(i-cam.i)*27+12
					--if #cards>7 then x=x+12 end
					local y=136-32
					if c.combo then for j,w in ipairs(c.combo) do if w[2]==i then y=y-8; rect(x,y,27,32,15); break end end end
					if coll(c.x,c.y,1,1, x,y,27,32) then
							--hover
								
							if btn(4) or left then 
									if sub(v,1,4)=='Plus' then
											if c.combo then for j,w in ipairs(c.combo) do if w[2]==i then goto skip end end end
											c.combo=c.combo or {}
											ins(c.combo,{v,i})
											table.sort(c.combo,function(a,b) return a[2]<b[2] end)
									else
									c.cardno=i
									end
									c.state=v
									sfx(4,12*3+5,12,2)
									::skip::
							end
							
							rectb(x,y,27,32,t%16)
							print(v,x+2,y+14+8,t%16,false,1,true)
							if v=="Attack" then spr(33,x+5,y+4,0,1,0,0,2,2) end
							if v=="Defend" then spr(35,x+5,y+4,0,1,0,0,2,2) end
							if v=="Spell" then spr(65,x+5,y+4,0,1,0,0,2,2) end
							if v=="Item" then spr(67,x+5,y+4,0,1,0,0,2,2) end
							if v=="Plus 1" then spr(97,x+5,y+4,0,1,0,0,2,2) end
							if v=="Plus 2" then spr(99,x+5,y+4,0,1,0,0,2,2) end
							if v=="Plus 3" then spr(129,x+5,y+4,0,1,0,0,2,2) end
							if v=="Draft" then spr(131,x+5,y+4,0,1,0,0,2,2) end
							if v=="Honey" then spr(163,x+5,y+4,0,1,0,0,2,2) end
							if v=="Spike" then spr(193,x+5,y+4,0,1,0,0,2,2) end
							if v=="Sleep" then spr(195,x+5,y+4,0,1,0,0,2,2) end
							if v=="Clone" then spr(225,x+5,y+4,0,1,0,0,2,2) end
					else
							rectb(x,y,27,32,1)
							print(v,x+2,y+14+8,1,false,1,true)
							if v=="Attack" then spr(33,x+5,y+4,0,1,0,0,2,2) end
							if v=="Defend" then spr(35,x+5,y+4,0,1,0,0,2,2) end
							if v=="Spell" then spr(65,x+5,y+4,0,1,0,0,2,2) end
							if v=="Item" then spr(67,x+5,y+4,0,1,0,0,2,2) end
							if v=="Plus 1" then spr(97,x+5,y+4,0,1,0,0,2,2) end
							if v=="Plus 2" then spr(99,x+5,y+4,0,1,0,0,2,2) end
							if v=="Plus 3" then spr(129,x+5,y+4,0,1,0,0,2,2) end
							if v=="Draft" then spr(131,x+5,y+4,0,1,0,0,2,2) end
							if v=="Honey" then spr(163,x+5,y+4,0,1,0,0,2,2) end
							if v=="Spike" then spr(193,x+5,y+4,0,1,0,0,2,2) end
							if v=="Sleep" then spr(195,x+5,y+4,0,1,0,0,2,2) end
							if v=="Clone" then spr(225,x+5,y+4,0,1,0,0,2,2) end
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
-- 065:0000000000000000000000000009900000099900000099990000999900099990
-- 066:0000000000900000099000009990000099900000999000000999999909909900
-- 067:0000000000000000000000000000009900000a99000000a0000000a0000000a0
-- 068:0000000000000000000000009900000099a000000a0000000a0000000a000000
-- 069:0000990000099000009900000990000009900000009900000009900000009900
-- 070:0099000000099000000099000000099000000990000099000009900000990000
-- 073:0000000000000000000000000000000000000000000000000000000c000ccccc
-- 074:00000000000000000000000000000000000000c000000c00ccccc000c77ccc00
-- 076:00000000000000000000000000000000000000000000000000000000000ccccc
-- 077:00000000000000000000000000000000000000000000000000000000cccc0000
-- 078:00000000000000000000000000000000000000c000000c00000c000000c00000
-- 079:000000000000000000000000000000000000000000000000000000000000cccc
-- 081:0099990009990000999909909909990000099909000990990009000900000009
-- 082:0000900000999000009999000009990099099990999099909000000000000000
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
-- 097:0000000000000000000000000000000000000000000000090000009900000999
-- 098:0000000000000000000000000000000000000000900000009900000099900000
-- 099:0000000000000000000099000009999000999999009999990009999000009900
-- 104:0000c7cc000c7ccc0007cc2c007c7cc20077cccc007ccccc00cccccc00cccccc
-- 105:cccc777ccccccc77cccccccc2222ccc2cccccccccccccccccccccccccccccccc
-- 106:c777ccc77ccccccccccc2ccc2222cccccccccccccccccccccccccccccccccccc
-- 107:c700000077000000c770000077700000c7700cc0cc770c7c7c77c7c7c7c7c777
-- 108:0000c7cc000c7ccc0007cc2c007c7cc20077cccc007ccccc00cccccc00cccccc
-- 109:cccccccccccccccccccccccc2222ccc2cccccccccccccccccccccccccccccccc
-- 110:ccccccc7cccccccccccc2ccc2222cccccccccccccccccccccccccccccccccccc
-- 111:c700000077000000c770000077700000c7700cc0cc770c7c7c77c7c7c7c7c777
-- 113:0000099900000099000000090000000000000000000000000000000000000000
-- 114:9990000099000000900000000000000000000000000000000000000000000000
-- 116:0099000009999000999999009999990009999000009900000000000000000000
-- 120:007c22c2007cc2220077c22c000c7ccc0077c7cc00777c7c0007770000077000
-- 121:22222222cccccccccccc77cccccccccccccccccccccccccc77ccccc700000000
-- 122:222c2ccccc222cc7cc22cccccccccc7ccccccc7ccc7cc770777c777000007700
-- 123:7c7c7770c77000007770000077000000c0000000000000000000000000000000
-- 124:007c22c2007cc2220077c22c000c7ccc0077c7cc00777c7c0007770000077000
-- 125:22222222cccccccccccc77cccccccccccccccccccccccccc77ccccc700000000
-- 126:222c2ccccc222cc7cc22cccccccccc7ccccccc7ccc7cc770777c777000007700
-- 127:7c7c7770c77000007770000077000000c0000000000000000000000000000000
-- 129:0000000000000009000000990000099900000999000000990000000900000000
-- 130:0000000090000000990000009990000099900000990000009000000000000000
-- 131:00aaaaaa00a0000000a0000000a0000000a0000000a0000000a0000000a00000
-- 132:aaaaaa0000000a0000000a0000000a0000000a0000000a0000000a0000000a00
-- 137:000000bb00000bbb0000bbbb0000bbbb000bbbbb000bbbbb000bbbbb000bbbbb
-- 138:b0000000bb300000bbb30000bbbb0000bbbb3000bbbb3000bbbb3000bbbb3300
-- 139:0000000000000000000000000000000000bbb00000bbbb0000bbbb000bbbbb00
-- 140:000000000000000000000bb00000bbbb000bbbbb000bbbbb000bbbb3000bbbb3
-- 141:000000bb00000bbb0000bbbb0000bbbb000bbbbb000bbbbb000bbbbb000bbbbb
-- 142:b0000000bb300000bbb30000bbbb0000bbbb3000bbbb3000bbbb3000bbbb3300
-- 145:0009900000999900099999900999999000999900000990000000000000000000
-- 146:0009900000999900099999900999999000999900000990000000000000000000
-- 147:00a0000000a0000000a0000000a0000000a0000000a0000000a0000000aaaaaa
-- 148:00000a0000000a0000000a0000000a0000000a0000000a0000000a00aaaaaa00
-- 152:00000bb00000bbbb000bbbbb000bbbbb000bbbb3000bbbb3000bbbb3000bbbb3
-- 153:00bbbbbb00bbbbbb00bbbbbb00bb2bbb00bb2bbb00bb2bbb00bb2bbb03bbbbbb
-- 154:bbbbb300bbbbb300bbbbb300b2bb3300b2bb3300b2bb330bb2bb33bbbbbb33bb
-- 155:0bbbb3000bbbb3000bbb33000bbb3300bbbb3300bbbb3300bbbb3300bbbb3000
-- 156:000bbbb3000bbbb3000bbbb3000bbbb3000bbbbb000bbbbb0000bbbb0000bbbb
-- 157:00bbbbbb00bbbbbb00bbbbbb00bb2bbb00bb2bbb30bb2bbbb3bb2bbbbbbbbbbb
-- 158:bbbbb300bbbbb300bbbbb300b2bb3300b2bb3300b2bb3300b2bb3300bbbb3300
-- 159:000000000000000000bbb00000bbbb0000bbbb000bbbbb000bbbb3000bbbb300
-- 161:00000000000000000000000a000000aa00000000000aa00000aa0a000aa00aaa
-- 162:0000000000000000aaaaa0000000aa00aa000aa00aa000aaaa0000aaa0000aa0
-- 163:0000000000000099000009000000090000999000090009000900090090000099
-- 164:0000000090000000090000000900000000999000090009000900090090000090
-- 168:000bbbb3000bbbb3000bbbbb000bbbbb0000bbbb0000bbbb0000bbbb0000bbbb
-- 169:03bbbbbb0bbbbb220bbbbb223bbbbb22bbbbbbbbbbbbbbbbb3bbbbbb3bbbbbbb
-- 170:bbbb3bbbbbbb3bbbbbbbb3bbbbbbb3bbbbbbb3b3bbbbbbb0bbbbbb00bbbbbb00
-- 171:bbb33000bb330000bb330000b300000030000000000000000000000000000000
-- 172:0000bbbb0000bbbb00000bb30000003300000003000000000000000000000000
-- 173:b3bbbbbb3bbbbb223bbbbb223bbbbb223bbbbbbb0bbbbbbb0bbbbbbb0bbbbbbb
-- 174:bbbb3300bbbb3000bbbbb000bbbbb00bbbbbb0bbbbbbbbbbbbbbbbbbbbbbbbbb
-- 175:0bbb33000bbb3300bbbb3300bbbb3300bbbb3300bbbb3000bbb33000bb330000
-- 177:aa000a00a0000000aa000aaa0aa00a0000aa0a00000aa0000000000000000000
-- 178:000aa0000aa00000a00000000000000000000000000000000000000000000000
-- 179:0900090009000900009990000000090000000900000000990000000000000000
-- 180:0900090009000900009990000900000009000000900000000000000000000000
-- 184:00000bb300000033000000030000000000000000000000000000000000000000
-- 185:3bbbbbbb3bbbbbbb3bbbbbbb0bbbbbbb0bbbbbbb0bbbbbbb0bbbbbbb0bbbbbbb
-- 186:bbbbbb00bbbb3000bbbb3000bbbb3000bbb30000bb330000bb330000bb330000
-- 189:0bbbbbbb0bbbbbbb0bbbbbbb0bbbbbbb0bbbbbbb0bbbbbbb0bbbbbbb0bbbbbbb
-- 190:bbb3bbbbbbb3bbbbbbbb3bb3bbbb3bb0bbb30000bb330000bb330000bb330000
-- 191:bb330000b3000000300000000000000000000000000000000000000000000000
-- 193:000000000000000a0000000a000000a0000000a000000a0900000a090000a090
-- 194:000000000000000000000000a0000000a00000000a0000000a00000000a00000
-- 195:00000000000000000aaaaa000a000a000aaa0a0000a00a000a00a0090a000a00
-- 196:0000000000000000000000000000000000000000000000009900000009000000
-- 200:eeeee000e000eee0000000ee0000000e000000ee00000ee30000ee33000ee333
-- 201:00000eee0000ee000000e0000000e000eeeee00033333ee0333333ee3333333e
-- 202:eee00000000ea000000aaaa000aaa3a00aaa333a0a3a3a330a33a3330a3a3a33
-- 203:0000000000000000000000000000000000000000a0000000a0aaaaa03aa333aa
-- 204:eeeee000e000eee0000000ee0000000e000000ee00000ee30000ee33000ee633
-- 205:00000eee0000ee000000e0000000e000eeeee00033333ee0333333ee3336633e
-- 206:eee0000a000e0aaa0000aa33000aa333000a3333000aa3a3000a3a33000aa3a3
-- 207:a0000000a00aaaa03aaa333a3a33333aaa33333aa3a3a33aaa3a333aa3a3a33a
-- 209:0000a090000a0900000a090000a0900000a09000000990000000099900000000
-- 210:00a00000000a0000000a00000000a0000000a000009900009900000000000000
-- 211:0aaaaa0000000009000000090000000000000000000000000000000000000000
-- 212:90000000000aaa0099000a00000a0000000aaa00000000000000000000000000
-- 216:000e6333000e663300093663000e33660009e333000093330000933300000933
-- 217:333363333336633333663333366333333333333e3333333e33333e9e3339e9e9
-- 218:eaa3a33ae0aa3a3ae0aaa33ae00a33aaeeee33aaeeeeeea3ee333eaae33333ee
-- 219:aa3a333aa3a3a3333a3a333aa3a333aa3333aaa0aaaaa000a000000000000000
-- 220:000e6663000e666600093666000e33660009e333000093330000933300000933
-- 221:336663333666633336663333366333333333333e3333333e33333e9e3339e9e9
-- 222:e00a3a3ae00aa3aae000aa3ae000a33aeeee333aeeeeeea3ee333eaae33333ee
-- 223:3a3a333aa3a333a03a333aa03333aa0033aa0000aaa00000a000000000000000
-- 225:0000000000000aaa00000a0000000a0000000a0000000a0000000a0000000a00
-- 226:00000000aaa00000000000000000000000a000000a0a0000a000a00000a00000
-- 232:0000009300000009000000000000000000000000000000090000009900000990
-- 233:39909e9e900099e3000099930009993309909933900009330000993300099933
-- 234:3333333e333333333333333e333333ee3333ee3e333333ee333e39e933939e9e
-- 235:e0000000ee000000ee000000eee00000eeee0000eeee0000eeeee000eeeee000
-- 236:0000009300000009000000000000000000000000000000090000009900000990
-- 237:39909e9e900099e3000099930009993309909933900009330000993300099933
-- 238:3333333e333333333333333e333333ee3333ee3e333333ee333e39e933939e9e
-- 239:e0000000ee000000ee000000eee00000eeee0000eeee0000eeeee000eeeee000
-- 241:00000a00000a000a0000a0a000000a00000000000000000000000aaa00000000
-- 242:00a0000000a0000000a0000000a0000000a0000000a00000aaa0000000000000
-- 248:0000090000009000000090090000000000000000000000000000000000000000
-- 249:0099009399900099900000090000009900009990009900000900099900009900
-- 250:3399e9e939399e9e999999e99999999300999999999000990000000000000000
-- 251:e3e3ee003e333e00e3333ee0e33333e0333333e0999e9e000000000000000000
-- 252:0000090000009000000090090000000000000000000000000000000000000000
-- 253:0099009399900099900000090000009900009990009900000900099900009900
-- 254:3399e9e939399e9e999999e99999999300999999999000990000000000000000
-- 255:e3e3ee003e333e00e3333ee0e33333e0333333e0999e9e000000000000000000
-- </TILES>

-- <SPRITES>
-- 001:000000550005555b0005bbbb005bbbbb005bbbbb005bbbbb0055bbbb0555bbbb
-- 002:55555555bbbbbbb5bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 003:005555b5555bbbbbb5bbbbbbbbbbbbbbbbbbbbbbb5bbbbbbb5bbbbbbb55bbbbb
-- 004:55000000b5500000bbb55000bbbb5000bbbb5500bbbbb500bbbbb500bbbb5500
-- 005:000000550005555b0005bbbb005bbbbb005bbbbb005bbbbb0055bbbb0555bbbb
-- 006:55555555bbbbbbb5bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 007:005555b5555bbbbbb5bbbbbbbbbbbbbbbbbbbbbbb5bbbbbbb5bbbbbbb55bbbbb
-- 008:55000000b5500000bbb55000bbbb5000bbbb5500bbbbb500bbbbb500bbbb5500
-- 017:055b5bbb55bbb55b5bbbbb555bbbbbb55bbbbbbb5b55bbbb5555bbbb05b55b55
-- 018:bbbbbbbbbbbbbbb5bbbbb55555555511bb411411bb41141151411111b5414411
-- 019:5555bbbb51155555111414b5411414bb411414bb411414bb4111141141144441
-- 020:bbb5b500bb55b500555bb500bbbbb550bbbbbb50bbbbb5005bbb555055555555
-- 021:055b5bbb55bbb55b5bbbbb555bbbbbb55bbbbbbb5b55bbbb5555bbbb05b55b55
-- 022:bbbbbbbbbbbbbbb5bbbbb55555555511bb411411bb41141151411111b5411111
-- 023:5555bbbb51155555111414b5411414bb411414bb411414bb4111141141111441
-- 024:bbb5b500bb55b500555bb500bbbbb550bbbbbb50bbbbb5005bbb555055555555
-- 033:555b555b55b5b5b55b555b5b55b555b505555b51055055110000000000000000
-- 034:5b411141b1414111541111111411111111411144004111410041144100141411
-- 035:4141114441114114411111141111111444411114114111411144114011141410
-- 036:b55b5b505b55b550b5b555501b55000011550000000000000000000000000000
-- 037:555b555b55b5b5b55b555b5b55b555b505555b51055055110000000000000000
-- 038:5b414111b1411441541111111411111111411144004114410041144100141411
-- 039:4111414441441114411111141111111444411114114411411144114011141410
-- 040:b55b5b505b55b550b5b555501b55000011550000000000000000000000000000
-- 049:0000000000000000000000000000000000000000000114440144444114111111
-- 050:0004141100141444004111110141441414111411411144111114411114441111
-- 051:1114140044441410111111404144114011411141114111441114111111144411
-- 052:0000000000000000000000000000000000000000411000001444411011114444
-- 053:0000000000000000000000000000000000000000000114440144444114111111
-- 054:0004144400141111004111140141441114111411411144111114411114441111
-- 055:4444140011111410411111401144114011411141114111441114111111144411
-- 056:0000000000000000000000000000000000000000411000001444411011114444
-- </SPRITES>

-- <WAVES>
-- 000:00000000ffffffff00000000ffffffff
-- 001:0123456789abcdeffedcba9876543210
-- 002:0123456789abcdef0123456789abcdef
-- 003:790b517a8ed8525a4ccb9cdc37bf1642
-- 004:003459deeedcb8544456678876421100
-- </WAVES>

-- <SFX>
-- 000:010001000200020002000200000000000000010002000100020002000100000001000100010001000100010001000100020002000200020002000200300000000000
-- 001:000000000000000000000000000000000000010001000100010001000100010001000000000000000000000000000000000000000000020002000200100000000000
-- 002:020002000200020002000200020002000200020002000200020002000200020002000200020002000100010001000100010001000000000000000200100000000000
-- 003:020002000200020002000200020002000200020001000200020002000200020000000200020002000200020001000100010001000100020001000100300000000000
-- 004:000001000200000001000200000001000200000001000200000001000200000001000200010001000100010001000100010000000100010001000100305000000000
-- 005:030003000300030003000300030003000300030003000300030003000300030003000300030003000300030003000300030003000300030003000300000000000000
-- 008:040004000400040004000400040004000400040004000400040004000400040004000400040004000400040004000400040004000400040004000400000000000000
-- 009:010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100000000000000
-- 010:020002000200020002000200020002000200020002000200020002000200020002000200020002000200020002000200020002000200020002000200000000000000
-- 011:150035005500650085009500b500c500e500f500f500f500f500f500f500f500f500f500f500f500f500f500f500f500f500f500f500f500f500f500409000000000
-- </SFX>

-- <PATTERNS>
-- 000:400088000000700088000000b00088000000e0008800000040008a000000000000000000022600000000000000000000044600000000000000000000066600000000000000000000000000000000000000000000000000000000000000000000400688000000700088000000b00088000000e0008800000040008a00000000000000000060008a00000040008a000000100000000000b00088000000000000000000100000000000b00088000000e00088000000900088000000100000000000
-- 001:900088000000000000000000000000000000500088000000700088000000000000000000022600000000000000000000044600000000000000000000066600000000000000000000000000000000000000000000000000000000000000000000900688000000000000000000400088000000000000100000400088000000700088000000900088000000e00086000000000000000000400088000000000000100000700088100000e00086000000b00086000000900086000000100000000000
-- 002:8881bc0000008000bc0000008000bc8000bc8000bc0000008000b60000000000000000008000bc0000008000bc0000008000bc0000008000bc0000008000bc8000bc8000bc0000008000b60000000000000000000000000000000000000000008000bc0000008000bc0000008000bc8000bc8000bc0000008000b60000000000000000008000bc0000008000bc0000008000bc0000008000bc0000008000bc8000bc8000bc0000008000b6000000000000000000000000000000000000000000
-- 003:400098000000b00096000000400098000000b00096100000b00096000000e00096000000400098000000700098000000b00098000000900098000000700098000000400098000000e00096000000b00096000000e00096000000400098000000400098000000b00096000000400098000000b00096000000900096000000b00096000000700096000000900096000000700096000000400096100000400096000000e00094000000400096000000e00094000000b00096000000e00096000000
-- 004:900096000000500096000000900096000000500096000000900096000000700096000000500096000000900096000000f00094100000f00094000000500096000000700096100000700096000000500096000000e00094000000b00094000000900094000000400096000000700096000000400096000000700096000000900096000000700096000000900096000000400096000000c00096000000e00096000000c00096000000700096000000e00096000000e00096000000400098000000
-- 005:400098000000e00096000000e00096000000900096000000900096000000e00096000000e00096000000700096000000b00096000000b00096000000700096000000b00096000000400096000000400096000000400096000000e00094000000e00096000000700098000000600098000000400098000000600098000000e00096000000900096000000e00096000000b00096000000900098000000700098000000900098000000e00098000000b00098000000900098000000e00098000000
-- 006:40009a00000040009a000000b0009800000040009a000000e00098000000e00098000000900098000000e00098000000b00098000000b00098000000b00098000000b00098000000900098000000b00098000000c00098000000b00098000000900098000000400098000000700098000000700098000000400098000000600098000000600098000000e00096000000400098000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 007:00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000040008a10000040008a100000e0008860008a70008a000000
-- </PATTERNS>

-- <TRACKS>
-- 000:1010c02410c01010c02410c00810c08c10c0000000000000000000000000000000000000000000000000000000000000000000
-- </TRACKS>

-- <PALETTE>
-- 000:140c1c44243430346d4e4a4e854c30346524d04648757161597dced27d2c8595a16daa2cd2aa996dc2cadad45edeeed6
-- </PALETTE>


-- title:  Card Grangers DX
-- author: verysoftwares.itch.io
-- desc:   minimalist card battles
-- script: lua
-- saveid: card-grangers

sub=string.sub
ins=table.insert
rem=table.remove

t=0
c={id="Player",state="card",hp=18,maxhp=18,honey=0,spike=0}
c.x=96
c.y=24
c.sprite=5
turn=c

cards={"Attack","Defend","Spell","Item"}--'Honey','Spike','Sleep','Clone'

top=""

allenemies={"Rocopter","Cactic","Bumbler",'Yggdra'}

drafted=0
defeated=0

encounter=1
function renemy(place)
		local out = {}
		local e = allenemies[math.random(#allenemies)]
		for i,f in ipairs(enemies) do if f.id==e then return renemy(place) end end
		out.id=e
		if out.id=="Rocopter" then if encounter==3 and find(old_enemies,out.id) then return renemy(place) end; out.sprite=76; out.hp=10-3; out.maxhp=10-3; out.atk=1 end
		if out.id=="Cactic" then if encounter==3 and find(old_enemies,out.id) then return renemy(place) end;  out.sprite=140; out.hp=16-3; out.maxhp=16-3; out.atk=2 end
		if out.id=="Bumbler" then if encounter==3 and find(old_enemies,out.id) then return renemy(place) end;  out.sprite=204; out.hp=9; out.maxhp=9; out.atk=3 end
		if out.id=="Yggdra" then if encounter<3 then return renemy(place) end; out.sprite=261; out.hp=16; out.maxhp=16; out.atk=0 end
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
		out.honey=0
		out.spike=0
		out.origi=#enemies+1
		return out		 
end

enemies={}
--ins(enemies,renemy(1))
--ins(enemies,renemy(3))
--enemies[#enemies].origi=3
ins(enemies,renemy(2))
maxnmy=1

--music(0)

function update()

	if peek(0x13FFC)==255 then music(0) end
	
	--if btn(0) and c.y>0 then c.y=c.y-1 end
	--if btn(1) and c.y<136-16 then c.y=c.y+1 end
	--if btn(2) and c.x>0 then c.x=c.x-1 end
	--if btn(3) and c.x<240-9 then c.x=c.x+1 end

	poke(0x3FFB,0) -- hide system cursor

	local mx,my,left=mouse()
	c.x=mx; c.y=my

	DJ()
		
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
									elseif enemycard(turn.id)=='Spike' then
											c.spike=c.spike+1
											c.spikemem=c.spikemem or {}
											local ei
											for i,e in ipairs(enemies) do if e==turn then ei=i; break end end
											for j,d in ipairs(c.spikemem) do if d[1]==ei then d[2]=d[2]+1; goto skip end end
											ins(c.spikemem,{ei,1})
											::skip::
											top=string.format('You now take %dx damage!',c.spike+1)
											turn.anim=140		
											turn.pending=nil
									elseif enemycard(turn.id)=='Sleep' then
											c.sleep=c.sleep or 0
											c.sleep=c.sleep+1
											if c.sleep==1 then
											top='You are now asleep!'
											else
											top=string.format('You are asleep for %d turns!',c.sleep)
											end
											turn.anim=140		
											turn.pending=nil
									elseif enemycard(turn.id)=='Clone' then
											if #enemies>1 and #enemies<4 then
											local cloned=enemies[math.random(#enemies)]
											while cloned==turn do cloned=enemies[math.random(#enemies)] end
											local out={}
											for k,v in pairs(cloned) do
													out[k]=v
											end
											local empty
											for d=1,#enemies do
													if enemies[d].origi~=d then empty=d; break end
											end

											if empty then ins(enemies,empty,out); out.origi=empty
											else ins(enemies,out) end
											if empty and #enemies<=maxnmy then 
											if #enemies==3 then out.x=80-40+20+(empty-1)*40 end
											if #enemies==4 then out.x=80-40+(empty-1)*40 end
											end
											top=string.format('Cloned %s.',cloned.id)
											turn.anim=140		
											turn.pending=nil

											if #enemies>maxnmy then
													if maxnmy==2 then
															enemies[1].x=80-40+20
															enemies[2].x=80+20
															enemies[3].x=80+40+20
													elseif maxnmy==3 then
															enemies[1].x=80-40
															enemies[2].x=80
															enemies[3].x=80+40
															enemies[4].x=80+40+40
													end
													maxnmy=#enemies
											end
											elseif #enemies==1 then
											top='Nobody left to clone!'
											turn.anim=140		
											turn.pending=nil
											elseif #enemies==4 then
											top='Enemy party is already full!'
											turn.anim=140		
											turn.pending=nil
											end
									else
											turn.pending=nil
											nextturn()
									end
							end
					end
			elseif turn.state=="card" then
					if c.defending and not c.sleep then
							local dmg=0
							for i,e in ipairs(enemies) do
									if not e.pending and not e.sleep then
									dmg=dmg+(e.atk-e.honey)*(c.spike+1)
									end
							end
							
							if math.abs(dmg)>0 then
							if #enemies>1 then
							top='Enemies were blocked.'
							else
							top=string.format('%s was blocked.',enemies[1].id)
							end
							else
							if #enemies>1 then
							top=string.format('Enemies deal no damage.')
							else
							top=string.format('%s deals no damage.',enemies[1].id)
							end
							end
							sfx(2,12*2,80,2)
							turn.state='hit'
							turn.anim=100
							turn.hit=nil
					else
							turn.hit=c
							local dmg=0
							for i,e in ipairs(enemies) do
									if not e.pending and not e.sleep then
									dmg=dmg+(e.atk-e.honey)*(turn.hit.spike+1)
									end
							end
							if math.abs(dmg)>0 then
							if #enemies>1 then
							top=string.format('Enemies hit you for %d HP!',dmg)
							else
							top=string.format('%s hit you for %d HP!',enemies[1].id,dmg)
							end
							sfx(1,12*2,80,2)
							else
							if #enemies>1 then
							top=string.format('Enemies deal no damage.')
							else
							top=string.format('%s deals no damage.',enemies[1].id)
							end
							sfx(2,12*2,80,2)
							end
							turn.state="hit"
							turn.anim=100
							turn.hit.hp=turn.hit.hp-dmg
							if turn.hit.hp>turn.hit.maxhp then turn.hit.hp=turn.hit.maxhp end
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
					enemydraw(e)
			end
			for i,e in ipairs(enemies) do	
			if not e.gone then print(string.format("%d/%d",e.hp,e.maxhp),e.x+4,e.y+32+2,1,false,1,true) end
			end
	end
	
	if card_ydist>0 then card_ydist=card_ydist-1 end

	local w= print(top,0,1,15)
	print(top,240/2-w/2,1,6)

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
	if keyp(18) then music(); reset() end
	end

	if encounter>=6 and c.state~='card' then
			local w=print('You win!',0,-12,15,false,2,false)
			print('You win!',240/2-w/2-1,80-24-8,1,false,2,false)
			print('You win!',240/2-w/2+1,80-24-8,1,false,2,false)
			print('You win!',240/2-w/2,80-24-8-1,1,false,2,false)
			print('You win!',240/2-w/2,80-24-8+1,1,false,2,false)
			local col=(t*FLASHSPD)%16
			if FLASHSPD==0 then col=14 end
			print('You win!',240/2-w/2,80-24-8,col,false,2,false)
	end

	spr(c.sprite,c.x,c.y,4,1,0,0,2,2)
	
	t=t+1
end

animcards={}
titlecards={'Play','Option','Creds'}

ADDR = 0x3FC0
palette = 0
function addLight(scnline)
  for j=0, 2 do
  	local col
   if j==0 then col=0x85 end
   if j==1 then col=0x4C end
   if j==2 then col=0x30 end
   poke(ADDR+4*3+j, col-0x30+palette)--+math.sin(scnline+t*0.2)*15)
  end
  palette = palette + 15
end

function SCN(scnline)
 if (TIC==titlescr) and (scnline) % 12 == 0 then
  addLight(scnline)
 end
end

function titlescr()
		if peek(0x13FFC)==255 then music(1) end
		poke(0x3FFB,0) -- hide system cursor
	
		cls(12)
		if newgame then clip(0,0,240,newgame*2); cls(15) end
		clip()
		
		old_left=left		
		mx,my,left=mouse()
		if not leftclick then
				leftclick=left and not old_left
		else
				leftclick=false
		end
		
		c.x=mx; c.y=my
		poke(0x3FFB,0) -- hide system cursor
		
		DJ()
		
		bg_t=bg_t or 0
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
		
		if #animcards==0 and not newgame then
				for i=1,8 do
						animcards[i]={x=-27*2+(i-1)*27*2,y=0+32,id=rcard2()}
				end
				for i=9,9+7 do
						animcards[i]={x=-27*2+(i-10)*27*2-27,y=0+32+32,id=rcard2()}
				end
				for i=9+7+1,9+7+1+7 do
						animcards[i]={x=-27*2+(i-(9+7+1)-1)*27*2,y=32+32+32,id=rcard2()}
				end
				for i=9+7+1+7+1,9+7+1+7+1+7 do
						animcards[i]={x=-27*2+(i-(9+7+1+7+1)-1)*27*2-27,y=32+32+32+32,id=rcard2()}
				end
		end
		for i,d in ipairs(animcards) do
				rect(d.x,d.y,27,32,15)
				rectb(d.x,d.y,27,32,1)
				if d.y>=136 then
				d.id=allcards[math.random(#allcards)]
				d.x=d.x+27*6+27+3; d.y=d.y-32*5-32
				end
				if d.id=="Attack" then spr(33,d.x+5,d.y+4,0,1,0,0,2,2) end
				if d.id=="Defend" then spr(35,d.x+5,d.y+4,0,1,0,0,2,2) end
    if d.id=="Spell" then spr(65,d.x+5,d.y+4,0,1,0,0,2,2) end
				if d.id=="Item" then spr(67,d.x+5,d.y+4,0,1,0,0,2,2) end
				if d.id=="Plus 1" then spr(97,d.x+5,d.y+4,0,1,0,0,2,2) end
				if d.id=="Plus 2" then spr(99,d.x+5,d.y+4,0,1,0,0,2,2) end
				if d.id=="Plus 3" then spr(129,d.x+5,d.y+4,0,1,0,0,2,2) end
				if d.id=="Draft" then spr(131,d.x+5,d.y+4,0,1,0,0,2,2) end
				if d.id=="Honey" then spr(163,d.x+5,d.y+4,0,1,0,0,2,2) end
				if d.id=="Spike" then spr(193,d.x+5,d.y+4,0,1,0,0,2,2) end
				if d.id=="Sleep" then spr(195,d.x+5,d.y+4,0,1,0,0,2,2) end
				if d.id=="Clone" then spr(225,d.x+5,d.y+4,0,1,0,0,2,2) end
				d.x=d.x-1; d.y=d.y+1
		end
		
		rect(0,136-32,240,32,15)

		card_ydist=card_ydist or 0
		if newgame then card_ydist=card_ydist+1 end
		
		for i,l in ipairs(titlecards) do
				local x=(i-1)*27+12
				local y=136-32+card_ydist
				rect(x,y,27,32,15)
				if coll(c.x,c.y,1,1, x,y,27,32) then
				local col
				if FLASHSPD==0 then col=14
				else col=(t*FLASHSPD)%16 end
				rectb(x,y,27,32,col)
				print(l,x+2,y+14+8,col,false,1,true)
				if (not newgame) and (btnp(4) or leftclick) then
						if i==1 then newgame=0 end
						if i==2 then TIC=options; c.state='card' end
						if i==3 then TIC=credits end
						sfx(4,12*3+5,12,2)
				end
				else
				rectb(x,y,27,32,1)
				print(l,x+2,y+14+8,1,false,1,true)
				end
				spr(85+(i-1)*(16*2),x+5,y+4,0,1,0,0,2,2)
		end
		
		dist=dist or 140

		if dropshadow then
		for i,v in ipairs(animcards) do
				clip(v.x,v.y,27,32)
				print('Card',240/2-60-30-1-dist+4,30-6-2+4,3,false,5,false)
				print('Card',240/2-60-30+1-dist+4,30-6-2+4,3,false,5,false)
				print('Card',240/2-60-30-dist+4,30-6-2-1+4,3,false,5,false)
				print('Card',240/2-60-30-dist+4,30-6-2+1+4,3,false,5,false)
				print('Card',240/2-60-30-dist+4,30-6-2+4,3,false,5,false)
				print('Grangers',240/2-60+40-30-1+dist+4,30+30-6-2+4,3,false,3,false)
				print('Grangers',240/2-60+40-30+1+dist+4,30+30-6-2+4,3,false,3,false)
				print('Grangers',240/2-60+40-30+dist+4,30+30-6-2-1+4,3,false,3,false)
				print('Grangers',240/2-60+40-30+dist+4,30+30-6-2+1+4,3,false,3,false)
				print('Grangers',240/2-60+40-30+dist+4,30+30-6-2+4,3,false,3,false)
				print('Deluxe',240/2-60+40-30-10-1-dist+4,30+30+20-6-2+4,3,false,2,false)
				print('Deluxe',240/2-60+40-30-10+1-dist+4,30+30+20-6-2+4,3,false,2,false)
				print('Deluxe',240/2-60+40-30-10-dist+4,30+30+20-6-2-1+4,3,false,2,false)
				print('Deluxe',240/2-60+40-30-10-dist+4,30+30+20-6-2+1+4,3,false,2,false)
				print('Deluxe',240/2-60+40-30-10-dist+4,30+30+20-6-2+4,3,false,2,false)
		end
		clip()
		end
		
		print('Card',240/2-60-30-1-dist,30-6-2,1,false,5,false)
		print('Card',240/2-60-30+1-dist,30-6-2,4,false,5,false)
		print('Card',240/2-60-30-dist,30-6-2-1,1,false,5,false)
		print('Card',240/2-60-30-dist,30-6-2+1,4,false,5,false)
		print('Card',240/2-60-30-dist,30-6-2,4,false,5,false)
		print('Grangers',240/2-60+40-30-1+dist,30+30-6-2,1,false,3,false)
		print('Grangers',240/2-60+40-30+1+dist,30+30-6-2,4,false,3,false)
		print('Grangers',240/2-60+40-30+dist,30+30-6-2-1,1,false,3,false)
		print('Grangers',240/2-60+40-30+dist,30+30-6-2+1,4,false,3,false)
		print('Grangers',240/2-60+40-30+dist,30+30-6-2,4,false,3,false)
		print('Deluxe',240/2-60+40-30-10-1-dist,30+30+20-6-2,2,false,2,false)
		print('Deluxe',240/2-60+40-30-10+1-dist,30+30+20-6-2,2,false,2,false)
		print('Deluxe',240/2-60+40-30-10-dist,30+30+20-6-2-1,2,false,2,false)
		print('Deluxe',240/2-60+40-30-10-dist,30+30+20-6-2+1,2,false,2,false)
		print('Deluxe',240/2-60+40-30-10-dist,30+30+20-6-2,1,false,2,false)

		if not newgame then dist=dist-6
		if dist<=0 then dist=0 end
		end
		if newgame then if newgame%2==0 then rem(animcards,#animcards) end; newgame=newgame+1; dist=dist+6; if #animcards==0 then music(); TIC=update; card_ydist=32; newgame=nil end end
	
		if btn(4) or left then c.sprite=37 else c.sprite=5 end
		spr(c.sprite,c.x,c.y,4,1,0,0,2,2)

		poke(ADDR+4*3,0x85)
		poke(ADDR+4*3+1,0x4C)
		poke(ADDR+4*3+2,0x30)
	
		palette=0
		
		t=t+1
end

TIC=titlescr

function credits()
		--poke4(0xFF9C*2+3,5)
		cls(15)
		
		old_left=left		
		mx,my,left=mouse()
		if not leftclick then
				leftclick=left and not old_left
		else
				leftclick=false
		end
		
		c.x=mx; c.y=my
		poke(0x3FFB,0) -- hide system cursor

		DJ()

		distb=distb or 0
		card_disty=card_disty or 0
		
		local cycle={6,9,12,15}
		for i=0,136,8 do
				local col=cycle[((i+t*0.4*FLASHSPD)//8)%4+1]
				if (i/8)%2==0 then
				rect(-distb,i,240,8,col)
				else
				rect(distb,i,240,8,col)
				end
				local col2=cycle[((i+t*0.4*FLASHSPD)//8+1)%4+1]
				if i==8*3 then 
				local w=print('Design, art, audio & code by',0,-6,col2,false,1,false)
				print('Design, art, audio & code by',240/2-w/2+distb,8*3+1,col2,false,1,false)
				end
				if i==8*4 then 
				local w=print('verysoftwares',0,-6,col2,false,1,false)
				print('verysoftwares',240/2-w/2-distb,8*4+1,col2,false,1,false)
				end
				if i==8*6 then 
				local w=print('Originally for Ludum Dare 43',0,-6,col2,false,1,false)
				print('Originally for Ludum Dare 43',240/2-w/2-distb,8*6+1,col2,false,1,false)
				end
				if i==8*8 then 
				local w=print('Special thanks to',0,-6,col2,false,1,false)
				print('Special thanks to',240/2-w/2-distb,8*8+1,col2,false,1,false)
				end
				if i==8*9 then 
				local w=print('Stefan & Yollie',0,-6,col2,false,1,false)
				print('Stefan & Yollie',240/2-w/2+distb,8*9+1,col2,false,1,false)
				end
		end

		rect(0,136-32,240,32,15)

		for i,l in ipairs(titlecards) do
				local x=(i-1)*27+12
				local y=136-32+card_disty
				rect(x,y,27,32,15)
				if coll(c.x,c.y,1,1, x,y,27,32) then
				local col
				if FLASHSPD==0 then col=14
				else col=(t*FLASHSPD)%16 end
				rectb(x,y,27,32,col)
				print(l,x+2,y+14+8,col,false,1,true)
				if (not newgame) and (btnp(4) or leftclick) then
						if i==1 then newgame=0 end
						if i==2 then TIC=options; c.state='card' end
						if i~=3 then sfx(4,12*3+5,12,2) end
				end
				else
				rectb(x,y,27,32,1)
				print(l,x+2,y+14+8,1,false,1,true)
				end
				spr(85+(i-1)*(16*2),x+5,y+4,0,1,0,0,2,2)
		end

		if coll(c.x,c.y,1,1, 240-27,136-32,27,32) then
				local col
				if FLASHSPD==0 then col=14
				else col=(t*FLASHSPD)%16 end
				rectb(240-27,136-32+card_disty,27,32,col)
				print('Skip',240-27+2,136-32+14+8+card_disty,col,false,1,true)
				spr(161,240-27+5,136-32+4+card_disty,0,1,0,0,2,2)
				if (not newgame) and (btn(4) or left) then
						TIC=titlescr
						sfx(4,12*3+5,12,2)
				end
		else
				rectb(240-27,136-32+card_disty,27,32,1)
				print('Skip',240-27+2,136-32+14+8+card_disty,1,false,1,true)
				spr(161,240-27+5,136-32+4+card_disty,0,1,0,0,2,2)
		end

		if newgame then 
		newgame=newgame+1 
		distb=distb+6
		if distb>=240 then
				local incr=6*4
				if distb>=240+incr*0 then
				rect(0,8,240,8,6+math.floor(((bg_t)*0.15+2)%3)*3)
				end
				if distb>=240+incr*1 then
				rect(0,16,240,8,6+math.floor(((bg_t)*0.15+1)%3)*3)
				end
				if distb>=240+incr*2 then
				rect(0,24,240,8,6+math.floor((bg_t*0.15)%3)*3)
				end
				if distb>=240+incr*3 then
				rect(0,72+24,240,8,6+math.floor(((bg_t)*0.15+2)%3)*3)
				end
				if distb>=240+incr*4 then
				rect(0,72+16,240,8,6+math.floor(((bg_t)*0.15+1)%3)*3)
				end
				if distb>=240+incr*5 then
				rect(0,72+8,240,8,6+math.floor((bg_t*0.15)%3)*3)
				end
				if distb>=240+incr*6 then
				rect(0,24+8,8,72-24,6+math.floor((bg_t*0.15)%3)*3)
				end
				if distb>=240+incr*7 then
				rect(8,24+8,8,72-24,6+math.floor(((bg_t)*0.15+1)%3)*3)
				end
				if distb>=240+incr*8 then
				rect(16,24+8,8,72-24,6+math.floor(((bg_t)*0.15+2)%3)*3)
				end
				if distb>=240+incr*9 then
				rect(240-8-0,24+8,8,72-24,6+math.floor((bg_t*0.15)%3)*3)
				end
				if distb>=240+incr*10 then
				rect(240-8-8,24+8,8,72-24,6+math.floor(((bg_t)*0.15+1)%3)*3)
				end
				if distb>=240+incr*11 then
				rect(240-8-16,24+8,8,72-24,6+math.floor(((bg_t)*0.15+2)%3)*3)
				end
				if distb>=240+incr*12 then
						newgame=nil; card_ydist=32; music(); TIC=update
				end
		end
		card_disty=card_disty+1
		end

		if btn(4) or left then c.sprite=37 else c.sprite=5 end
		spr(c.sprite,c.x,c.y,4,1,0,0,2,2)

		t=t+1
end

optcards={'Plus 0','Plus 1','Plus 2','Plus 3'}

function nonplussed()
		for i=0,3 do
				if not find(optcards,string.format('Plus %d',i)) then return true end
		end
		for i,v in ipairs({'Music','SFX','Flash'}) do
				if find(optcards,v) then return false end
		end
		return true
end

MUSICVOL=5/6*15
SFXVOL=5/6*15
FLASHSPD=1
if pmem(0)>0 then MUSICVOL=pmem(0)-1 end
if pmem(1)>0 then SFXVOL=pmem(1)-1 end
if pmem(2)>0 then FLASHSPD=(pmem(2)-1)/10 end

function DJ()
		local fade=0
		if newgame then fade=newgame*0.2; if fade>MUSICVOL then fade=MUSICVOL end end
		poke4(0x14000*2,math.floor(MUSICVOL-fade))
		poke4(0x14000*2+1,math.floor(MUSICVOL-fade))
		poke4(0x14000*2+2,math.floor(MUSICVOL-fade))
		poke4(0x14000*2+3,math.floor(MUSICVOL-fade))
		poke4(0x14000*2+4,math.floor(SFXVOL))
		poke4(0x14000*2+5,math.floor(SFXVOL))
		poke4(0x14000*2+6,math.floor(8/15*MUSICVOL-8/15*fade))
		poke4(0x14000*2+7,math.floor(8/15*MUSICVOL-8/15*fade))
		--poke4(0xFF9C*2+(3+1+32)+3,math.floor(MUSICVOL))
		--poke4(0xFF9C*2+(3+1+32)*2+3,math.floor(SFXVOL))
		--poke4(0xFF9C*2+(3+1+32)*3+3,math.floor(8/15*MUSICVOL))
end

function options()
		cls(12)

		old_left=left		
		mx,my,left,_,right=mouse()
		if not leftclick then
				leftclick=left and not old_left
		else
				leftclick=false
		end

		c.x=mx; c.y=my
		poke(0x3FFB,0) -- hide system cursor
		
		DJ()
		
		bg_t=bg_t or 0
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

		rect(0,136-32,240,32,15)
		rect(0,0,240,8,15)
		
		if right then
				c.combo=nil
				local select=false
				for i,v in ipairs({'Music','SFX','Flash'}) do if find(optcards,v) then select=true; break end end
				if select then c.state='idle' end
		end
		
		if 1 then--c.state=="card" or nonplussed() then
				local select=false
				for i,v in ipairs({'Music','SFX','Flash'}) do if find(optcards,v) then select=true; break end end
				if c.state=='card' then 
						if not select then top='Pick an option card.' 
						else top='Make a combo.' end
				end
				if (not deckcards) or #deckcards==0 then deckcards={}; for i,v in ipairs({'Music','SFX','Flash'}) do if not find(optcards,v) then ins(deckcards,v) end end; for i=0,3 do if not find(optcards,string.format('Plus %d',i)) then ins(deckcards,string.format('Plus %d',i)) end end end
				local x=80
				--if #deckcards>3 then end
				x=x-(#deckcards-3)*27/2 

				for i,v in ipairs(deckcards) do
						rect(x+(i-1)*27,40,27,32,15)
						if coll(c.x,c.y,1,1, x+(i-1)*27,40,27,32) then
								local col
								if FLASHSPD==0 then col=14
								else col=(t*FLASHSPD)%16 end				
								rectb(x+(i-1)*27,40,27,32,col)
								print(v,x+(i-1)*27+2,40+14+8,col,false,1,true)
								if v=="Music" then spr(181,x+(i-1)*27+5,40+4,0,1,0,0,2,2) end
								if v=="SFX" then spr(213,x+(i-1)*27+5,40+4,0,1,0,0,2,2) end
								if v=="Flash" then spr(227,x+(i-1)*27+5,40+4,0,1,0,0,2,2) end
								if v=="Plus 1" then spr(97,x+(i-1)*27+5,40+4,0,1,0,0,2,2) end
								if v=="Plus 2" then spr(99,x+(i-1)*27+5,40+4,0,1,0,0,2,2) end
								if v=="Plus 3" then spr(129,x+(i-1)*27+5,40+4,0,1,0,0,2,2) end
								
								if btnp(4) or leftclick then
										table.insert(optcards,v)
										local select=false
										for i,v in ipairs({'Music','SFX','Flash'}) do if find(optcards,v) then select=true; break end end
										if select then c.state="idle" end
										deckcards=nil
										c.combo=nil
										top=''
										sfx(4,12*3+5,12,2)
										return
								end
								
						else
								rectb(x+(i-1)*27,40,27,32,1)
								print(v,x+(i-1)*27+2,40+14+8,1,false,1,true)
								if v=="Music" then spr(181,x+(i-1)*27+5,40+4,0,1,0,0,2,2) end
								if v=="SFX" then spr(213,x+(i-1)*27+5,40+4,0,1,0,0,2,2) end
								if v=="Flash" then spr(227,x+(i-1)*27+5,40+4,0,1,0,0,2,2) end
								if v=="Plus 1" then spr(97,x+(i-1)*27+5,40+4,0,1,0,0,2,2) end
								if v=="Plus 2" then spr(99,x+(i-1)*27+5,40+4,0,1,0,0,2,2) end
								if v=="Plus 3" then spr(129,x+(i-1)*27+5,40+4,0,1,0,0,2,2) end
						end
				end
		end

		if c.state=='hit' then
				if c.anim then
						c.anim=c.anim-1
						if c.anim<=0 then c.state='card'; c.anim=nil end
				end
		end
		
		if c.state=='idle' then
				if mustbecombod_t then
						mustbecombod_t=mustbecombod_t-1
						if mustbecombod_t<=0 then mustbecombod_t=nil end
				else top='Now make a combo.' end
		end

		for i,l in ipairs(optcards) do
				local x=(i-1)*27+12
				local y=136-32
				if c.combo then for j,w in ipairs(c.combo) do if w[2]==i then y=y-8; rect(x,y,27,32,15); break end end end
				rect(x,y,27,32,15)
				if coll(c.x,c.y,1,1, x,y,27,32) then
				local col
				if FLASHSPD==0 then col=14
				else col=(t*FLASHSPD)%16 end
				rectb(x,y,27,32,col)
				print(l,x+2,y+14+8,col,false,1,true)
				if (c.state=='idle' or sub(c.state,1,4)=='Plus') and (btnp(4) or leftclick) then
						if (l=='Music' or l=='SFX' or l=='Flash') then
								if not c.combo then
								top='This card must be combo\'d with a Plus card.'
								mustbecombod_t=140
								else
										if l=='Music' then MUSICVOL=15/6*combovalue(); top=string.format('Music volume set to %d/6.',combovalue()); pmem(0,math.floor(MUSICVOL+1)) end
										if l=='SFX' then SFXVOL=15/6*combovalue(); top=string.format('SFX volume set to %d/6.',combovalue()); pmem(1,math.floor(SFXVOL+1)) end
										if l=='Flash' then FLASHSPD=combovalue()*0.2; top=string.format('Flashing speed set to %d/6.',combovalue()); pmem(2,math.floor(FLASHSPD*10+1)) end
										c.state='hit'
										c.anim=140
										c.cardno=i
										clearcards(optcards)
										deckcards=nil
										c.combo=nil
										mustbecombod_t=nil
										sfx(4,12*3+5,12,2)
								end
						else
						if sub(l,1,4)=='Plus' then
								if c.combo then for j,w in ipairs(c.combo) do if w[2]==i then goto skip end end end
								c.combo=c.combo or {}
								ins(c.combo,{l,i})
								table.sort(c.combo,function(a,b) return a[2]<b[2] end)
						else
						c.cardno=i
						end
						c.state=l
						sfx(4,12*3+5,12,2)
						::skip::						
						end
				end
				else
				rectb(x,y,27,32,1)
				print(l,x+2,y+14+8,1,false,1,true)
				end
				if l=='Plus 1' then spr(97,x+5,y+4,0,1,0,0,2,2) end
				if l=='Plus 2' then spr(99,x+5,y+4,0,1,0,0,2,2) end
				if l=='Plus 3' then spr(129,x+5,y+4,0,1,0,0,2,2) end
				if l=="Music" then spr(181,x+5,y+4,0,1,0,0,2,2) end
				if l=="SFX" then spr(213,x+5,y+4,0,1,0,0,2,2) end
				if l=="Flash" then spr(227,x+5,y+4,0,1,0,0,2,2) end
		end

		if coll(c.x,c.y,1,1, 240-27,136-32,27,32) then
				local col
				if FLASHSPD==0 then col=14
				else col=(t*FLASHSPD)%16 end
				rectb(240-27,136-32,27,32,col)
				print('Skip',240-27+2,136-32+14+8,col,false,1,true)
				spr(161,240-27+5,136-32+4,0,1,0,0,2,2)
				if btnp(4) or leftclick then
						optcards={'Plus 0','Plus 1','Plus 2','Plus 3'}
						deckcards=nil
						c.state='card'
						c.combo=nil
						TIC=titlescr
						sfx(4,12*3+5,12,2)
				end
		else
				rectb(240-27,136-32,27,32,1)
				print('Skip',240-27+2,136-32+14+8,1,false,1,true)
				spr(161,240-27+5,136-32+4,0,1,0,0,2,2)
		end
		
		if btn(4) or left then c.sprite=37 else c.sprite=5 end
		spr(c.sprite,c.x,c.y,4,1,0,0,2,2)
		
		local w= print(top,0,1,15)
		print(top,240/2-w/2,1,6)

		t=t+1
end

function enemycard(id)
		if id=='Rocopter' then return 'Sleep' end
		if id=='Cactic' then return 'Spike' end
		if id=='Bumbler' then return 'Honey' end
		if id=='Yggdra' then return 'Clone' end
end

function nextturn()
		if turn==c then
				--turn=enemies[1]
				if c.sleep then c.sleep=c.sleep-1; if c.sleep<=0 then c.sleep=nil end end
				turn=enemies
				for i,e in ipairs(enemies) do
						if (not e.sleep) and math.random(1,4)==1 then
								e.pending=true
						end
				end
				if #enemies==0 then
						encounter=encounter+1
						turn=c
						turn.state="card"
						if encounter==2 then
								ins(enemies,renemy(4))
								ins(enemies,renemy(5))
								maxnmy=2
								old_enemies={}
								for i,e in ipairs(enemies) do
										ins(old_enemies,e.id)
								end
						elseif encounter==3 then
								ins(enemies,renemy(4))
								ins(enemies,renemy(5))
								maxnmy=2
						elseif encounter==4 then
								ins(enemies,renemy(1))
								ins(enemies,renemy(2))
								ins(enemies,renemy(3))
								maxnmy=3
						elseif encounter==5 then
						  ins(enemies,renemy(6))
								ins(enemies,renemy(7))
								ins(enemies,renemy(8))
								ins(enemies,renemy(9))
								maxnmy=4
						else
								turn.state='idle'
								turn.combo=nil
						end
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
						sfx(6,'A-5',80,2)
				end
		end
		for i,e in ipairs(enemies) do
				enemydraw(e)
		end
		for i,e in ipairs(enemies) do	
		if not e.gone then print(string.format("%d/%d",e.hp,e.maxhp),e.x+4,e.y+32+2,1,false,1,true) end
		end
end

draftcards={"Attack","Defend","Spell","Item",'Plus 1','Plus 2','Plus 3','Draft'}
allcards={"Attack","Defend","Spell","Item",'Plus 1','Plus 2','Plus 3','Draft','Honey','Spike','Sleep','Clone'}

function rcard()
		return draftcards[math.random( #draftcards )]
end
function rcard2()
		return allcards[math.random( #allcards )]
end

function clearcards(tbl)
		tbl=tbl or cards
		if c.combo then 
		local cno_rem=false
		for j=#c.combo,1,-1 do
				local w=c.combo[j]; 
				if (not cno_rem) and c.cardno>w[2] then
				rem(tbl,c.cardno)
				cno_rem=true
				end
				rem(tbl,w[2])
				if (not cno_rem) and c.cardno<w[2] and ((not c.combo[j-1]) or (c.combo[j-1] and c.cardno>c.combo[j-1][2])) then
				rem(tbl,c.cardno)
				cno_rem=true
				end
		end
		else
		table.remove(tbl,c.cardno)
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

function enemydraw(e)
		if not e.gone then
		local sp=e.sprite-t%60//50*4
		if e.sleep then sp=e.sprite end
		spr(sp,e.x,e.y,0,1,0,0,4,4)
		end
end

cam={i=1}
function cursorctrl()
	old_left=left
	_,_,left,_,right=mouse()
	if not leftclick then
			leftclick=left and not old_left
	else
			leftclick=false
	end

	if c.state~='card' and c.state~='hit' and c.state~='waitsfx' then
			if coll(c.x,c.y,1,1, 240-27,136-32,27,32) then
					local col
					if FLASHSPD==0 then col=14
					else col=(t*FLASHSPD)%16 end
					rectb(240-27,136-32,27,32,col)
					print('Skip',240-27+2,136-32+14+8,col,false,1,true)
					spr(161,240-27+5,136-32+4,0,1,0,0,2,2)
					if btn(4) or left then
							sfx(4,12*3+5,12,2)
							c.state='waitsfx'
							c.draftt=30
					end
			else
					rectb(240-27,136-32,27,32,1)
					print('Skip',240-27+2,136-32+14+8,1,false,1,true)
					spr(161,240-27+5,136-32+4,0,1,0,0,2,2)
			end
	end

	if c.state=='waitsfx' then
			top=''
			c.draftt=c.draftt-1
			if c.draftt<=0 then
					c.draftt=nil
					nextturn()
			end
	end

	if c.state=="card" then
			if c.draft and c.maxdraft>1 then
			top = string.format("Pick 1, discard 2. (%d/%d)",c.maxdraft-c.draft+1,c.maxdraft)
			else
			top = "Pick 1, discard 2."
			end
			if (not deckcards) or #deckcards<=3 then 
					deckcards=deckcards or {}
					c.deck_t=c.deck_t or 0
					if #deckcards<3 then if c.deck_t%12==0 then ins(deckcards,rcard()) end end
					c.deck_t=c.deck_t+1
			end

			for i,v in ipairs(deckcards) do
					local y=40
					if c.deck_t<12 and i==1 then y=y-(12-c.deck_t%12) end
					if c.deck_t>=12 and c.deck_t<24 and i==2 then y=y-(12-c.deck_t%12) end
					if c.deck_t>=24 and c.deck_t<36 and i==3 then y=y-(12-c.deck_t%12) end
					rect(80+(i-1)*27,y,27,32,15)
					if coll(c.x,c.y,1,1, 80+(i-1)*27,y,27,32) then
							local col
							if FLASHSPD==0 then col=14
							else col=(t*FLASHSPD)%16 end
							rectb(80+(i-1)*27,y,27,32,col)
							print(v,80+(i-1)*27+2,y+14+8,col,false,1,true)
							if v=="Attack" then spr(33,80+(i-1)*27+5,y+4,0,1,0,0,2,2) end
							if v=="Defend" then spr(35,80+(i-1)*27+5,y+4,0,1,0,0,2,2) end
       if v=="Spell" then spr(65,80+(i-1)*27+5,y+4,0,1,0,0,2,2) end
							if v=="Item" then spr(67,80+(i-1)*27+5,y+4,0,1,0,0,2,2) end
							if v=="Plus 1" then spr(97,80+(i-1)*27+5,y+4,0,1,0,0,2,2) end
							if v=="Plus 2" then spr(99,80+(i-1)*27+5,y+4,0,1,0,0,2,2) end
							if v=="Plus 3" then spr(129,80+(i-1)*27+5,y+4,0,1,0,0,2,2) end
							if v=="Draft" then spr(131,80+(i-1)*27+5,y+4,0,1,0,0,2,2) end
							if v=="Honey" then spr(163,80+(i-1)*27+5,y+4,0,1,0,0,2,2) end
							if v=="Spike" then spr(193,80+(i-1)*27+5,y+4,0,1,0,0,2,2) end
							if v=="Sleep" then spr(195,80+(i-1)*27+5,y+4,0,1,0,0,2,2) end
							if v=="Clone" then spr(225,80+(i-1)*27+5,y+4,0,1,0,0,2,2) end

							if btnp(4) or leftclick then
									table.insert(cards,v)
									drafted=drafted+1
									if c.draft then c.draft=c.draft-1; if c.draft<=0 then c.draft=nil; c.maxdraft=nil; c.state='waitsfx'; c.draftt=30 end
									elseif not c.draft then c.state="idle" end
									deckcards=nil
									c.combo=nil
									c.deck_t=nil
									sfx(4,12*3+5,12,2)
									return
							end
							
					else
							rectb(80+(i-1)*27,y,27,32,1)
							print(v,80+(i-1)*27+2,y+14+8,1,false,1,true)
							if v=="Attack" then spr(33,80+(i-1)*27+5,y+4,0,1,0,0,2,2) end
							if v=="Defend" then spr(35,80+(i-1)*27+5,y+4,0,1,0,0,2,2) end
       if v=="Spell" then spr(65,80+(i-1)*27+5,y+4,0,1,0,0,2,2) end
							if v=="Item" then spr(67,80+(i-1)*27+5,y+4,0,1,0,0,2,2) end
							if v=="Plus 1" then spr(97,80+(i-1)*27+5,y+4,0,1,0,0,2,2) end
							if v=="Plus 2" then spr(99,80+(i-1)*27+5,y+4,0,1,0,0,2,2) end
							if v=="Plus 3" then spr(129,80+(i-1)*27+5,y+4,0,1,0,0,2,2) end
							if v=="Draft" then spr(131,80+(i-1)*27+5,y+4,0,1,0,0,2,2) end
							if v=="Honey" then spr(163,80+(i-1)*27+5,y+4,0,1,0,0,2,2) end
							if v=="Spike" then spr(193,80+(i-1)*27+5,y+4,0,1,0,0,2,2) end
							if v=="Sleep" then spr(195,80+(i-1)*27+5,y+4,0,1,0,0,2,2) end
							if v=="Clone" then spr(225,80+(i-1)*27+5,y+4,0,1,0,0,2,2) end
					end
			end

			for i=cam.i,cam.i+6 do
					local v=cards[i]
					if not v then break end
					local x=(i-cam.i)*27+12
					local y=136-32+card_ydist
					if (not c.sleep) and coll(c.x,c.y,1,1, x,136-32,27,32) then
							--hover
							local col
							if FLASHSPD==0 then col=14
							else col=(t*FLASHSPD)%16 end						
							rectb(x,y,27,32,col)
							print(v,x+2,y+14+8,col,false,1,true)
					else
							rectb(x,y,27,32,1)
							print(v,x+2,y+14+8,1,false,1,true)
					end
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
					if c.sleep then
							for i=1,7 do
							line(x,136-32+i,x+27-1,136-32+32-8+i,6)
							end
					end
			end
	end
	if c.state=="hit" then	
			for i,e in ipairs(enemies) do
					if c.hit==e or c.hit==enemies then
							if t%12<6 then 	
									enemydraw(e)
							end
					else
							enemydraw(e)
					end
			end
			c.anim=c.anim-1
			if c.anim==0 then 
			local honeyrem=false
			local spikerem=false
			local enemyloot=false
			for i=#enemies,1,-1 do
					local e=enemies[i]
					if e.hp<=0 then e.gone=true end
			end
			local i=1
			while i<=#enemies do
					local e=enemies[i]
					if e.hp<=0 then if not e.loot then
					c.anim=140; c.hit=nil;
					top=string.format('%s dropped loot: %s!',e.id,enemycard(e.id))
					ins(cards,enemycard(e.id))
					drafted=drafted+1
					enemyloot=true
					e.loot=true
					--e.gone=true
					defeated=defeated+1
					break
					else
					if c.honeymem then for j,d in ipairs(c.honeymem) do
							if d[1]==i then c.honey=c.honey-d[2]; rem(c.honeymem,j); top=string.format('You are free from %s\'s Honey!',e.id); c.anim=140; c.hit=nil; honeyrem=true break end
					end end
					if c.spikemem then for j,d in ipairs(c.spikemem) do
							if d[1]==i then c.spike=c.spike-d[2]; rem(c.spikemem,j); top=string.format('You are free from %s\'s Spike!',e.id); c.anim=140; c.hit=nil; spikerem=true break end
					end end
					end 
					table.remove(enemies,i)
					i=i-1
					end
					i=i+1
			end
			if not honeyrem and not spikerem and not enemyloot then
			c.state="idle"; nextturn(); 
			for i,e in ipairs(enemies) do 
					if not e.justslept then
					if e.sleep then e.sleep=e.sleep-1; if e.sleep<=0 then e.sleep=nil end end 
					else
					e.justslept=false
					end
			end
			return
			end
			end
	else
			if c.state~="card" then
					for i,e in ipairs(enemies) do
							enemydraw(e)
					end
					for i,e in ipairs(enemies) do	
					print(string.format("%d/%d",e.hp,e.maxhp),e.x+4,e.y+32+2,1,false,1,true)
					end
			end
	end
	
	if c.state~="idle" and c.state~="hit" and c.state~="card" and c.state~='waitsfx' then
			if btn(5) or right then c.state="idle"; c.combo=nil; c.cardno=nil; top='Nevermind.'; onlypick1_t=nil; cloneitself_t=nil; nevermind_t=60 end
	end
	if c.state=="Spell" then
			if c.combo then top=string.format('Hit all enemies for %d+%d HP.',1-c.honey,combovalue())
			else top=string.format("Hit all enemies for %d HP.",1-c.honey) end
			c.state="hit"
			c.hit=enemies
			for i,e in ipairs(enemies) do
					e.hp=e.hp-(1+combovalue()-c.honey)*(e.spike+1)
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
					if c.combo then top=string.format('Hit %s for %d+%d HP.',e.id,(2-c.honey)*(e.spike+1),combovalue()*2)
					else top=string.format("Hit %s for %d HP.",e.id,(2-c.honey)*(e.spike+1)) end
					sfx(3,12*3+5,80,2)
					c.state="hit"
					c.anim=90
					c.hit=enemies[1]
					c.hit.hp=c.hit.hp-(2+combovalue()*2-c.honey)*(e.spike+1)
					if c.hit.hp>c.hit.maxhp then c.hit.hp=c.hit.maxhp end 
					clearcards()
			else
			for i,e in ipairs(enemies) do
					if coll(c.x,c.y,1,1, e.x,e.y,32,32) then
							--hover
							local w=print(e.id,0,-6,15,false,1,true)
							rect(c.x+9,c.y,w+1,7,1)
							print(e.id,c.x+9+1,c.y+1,15,false,1,true)
							if btn(4) or left then
									if c.combo then top=string.format('Hit %s for %d+%d HP.',e.id,(2-c.honey)*(e.spike+1),combovalue()*2)
									else top=string.format("Hit %s for %d HP.",e.id,(2-c.honey)*(e.spike+1)) end
									sfx(3,12*3+5,80,2)
									c.state="hit"
									c.anim=90
									c.hit=e
									c.hit.hp=c.hit.hp-(2+combovalue()*2-c.honey)*(e.spike+1)
									if c.hit.hp>c.hit.maxhp then c.hit.hp=c.hit.maxhp end 
									clearcards()
							end
					end
			end
			end
	end
	if c.state=='Honey' then
			top = "Honey whom?"
			if #enemies==1 then
					local e=enemies[1]
					e.honey=e.honey+1
					if c.combo then top=string.format('%s\'s attack is weakened by %d+%d.',e.id,e.honey,combovalue())
					else top=string.format('%s\'s attack is weakened by %d.',e.id,e.honey) end
					if c.combo then e.honey=e.honey+combovalue() end
					sfx(3,12*3+5,80,2)
					c.state="hit"
					c.hit=e
					c.anim=120
					clearcards()
			else
			for i,e in ipairs(enemies) do
					if coll(c.x,c.y,1,1, e.x,e.y,32,32) then
							--hover
							local w=print(e.id,0,-6,15,false,1,true)
							rect(c.x+9,c.y,w+1,7,1)
							print(e.id,c.x+9+1,c.y+1,15,false,1,true)
							if btn(4) or left then
									e.honey=e.honey+1
									if c.combo then top=string.format('%s\'s attack is weakened by %d+%d.',e.id,e.honey,combovalue())
									else top=string.format('%s\'s attack is weakened by %d.',e.id,e.honey) end
									if c.combo then e.honey=e.honey+combovalue() end
									sfx(3,12*3+5,80,2)
									c.state="hit"
									c.hit=e
									c.anim=120
									clearcards()
							end
					end
			end
			end
	end
	if c.state=='Spike' then
			top = "Spike whom?"
			if #enemies==1 then
					local e=enemies[1]
					e.spike=e.spike+1
					if c.combo then e.spike=e.spike+combovalue() end
					top=string.format('%s now takes %dx damage!',e.id,e.spike+1)
					sfx(3,12*3+5,80,2)
					c.state="hit"
					c.hit=e
					c.anim=120
					clearcards()
			else
			for i,e in ipairs(enemies) do
					if coll(c.x,c.y,1,1, e.x,e.y,32,32) then
							--hover
							local w=print(e.id,0,-6,15,false,1,true)
							rect(c.x+9,c.y,w+1,7,1)
							print(e.id,c.x+9+1,c.y+1,15,false,1,true)
							if btn(4) or left then
									e.spike=e.spike+1
									if c.combo then e.spike=e.spike+combovalue() end
									top=string.format('%s now takes %dx damage!',e.id,e.spike+1)
									sfx(3,12*3+5,80,2)
									c.state="hit"
									c.hit=e
									c.anim=120
									clearcards()
							end
					end
			end
			end
	end
	if c.state=='Sleep' then
			top = "Sleep whom?"
			if #enemies==1 then
					local e=enemies[1]
					e.sleep=e.sleep or 0
					top=string.format('%s is asleep for %d turns.',e.id,e.sleep+1+combovalue())
					e.sleep=e.sleep+1+combovalue()
					sfx(3,12*3+5,80,2)
					c.state="hit"
					c.hit=e
					c.anim=120
					clearcards()
					e.justslept=true
			else
			for i,e in ipairs(enemies) do
					if coll(c.x,c.y,1,1, e.x,e.y,32,32) then
							--hover
							local w=print(e.id,0,-6,15,false,1,true)
							rect(c.x+9,c.y,w+1,7,1)
							print(e.id,c.x+9+1,c.y+1,15,false,1,true)
							if btn(4) or left then
									e.sleep=e.sleep or 0
									if not c.combo then
									top=string.format('%s is asleep for %d turn.',e.id,e.sleep+1+combovalue())
									else
									top=string.format('%s is asleep for %d turns.',e.id,e.sleep+1+combovalue())
									end
									e.sleep=e.sleep+1+combovalue()
									sfx(3,12*3+5,80,2)
									c.state="hit"
									c.hit=e
									c.anim=120
									clearcards()
									e.justslept=true
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
	if c.state=='Clone' then
			if not cloneitself_t then 
			top='Clone which card?'
			else
					cloneitself_t=cloneitself_t-1
					if cloneitself_t<=0 then cloneitself_t=nil end
			end
			for i=cam.i,cam.i+6 do
					local v=cards[i]
					if not v then break end
					local x=(i-cam.i)*27+12
					--if #cards>7 then x=x+12 end
					local y=136-32+card_ydist
					if c.combo then for j,w in ipairs(c.combo) do if w[2]==i then y=y-8; rect(x,y,27,32,15); break end end end
					if i==c.cardno then y=y-8; rect(x,y,27,32,15) end
					if (not c.sleep) and coll(c.x,c.y,1,1, x,y,27,32) then
							--hover
								
							if btn(4) or leftclick then
									if i~=c.cardno and ((not c.combo) or i~=c.combo[1][2]) then 
									for j=1,1+combovalue() do
											ins(cards,v)
											drafted=drafted+1
									end
									if not c.combo then
									top=string.format('Cloned %s.',v)
									else
									top=string.format('Cloned %s %d times.',v,1+combovalue())
									end
									c.state='hit'
									c.anim=120
									cloneitself_t=nil
									clearcards()
									else
									if i==c.cardno then
									top='The card can\'t clone itself.'
									cloneitself_t=100
									elseif c.combo and i==c.combo[1][2] then
									top='The card can\'t clone its own combo card.'
									cloneitself_t=100
									end
									end
							end

							local col
							if FLASHSPD==0 then col=14
							else col=(t*FLASHSPD)%16 end
							rectb(x,y,27,32,col)
							print(v,x+2,y+14+8,col,false,1,true)
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
	if not onlypick1_t then
	if sub(c.state,1,4)=='Plus' then
			top='Select a combo card.'
	end
	if c.state=="idle" then
			if nevermind_t then nevermind_t=nevermind_t-1; if nevermind_t<=0 then nevermind_t=nil end 
			else top="Select an action." end
	end
	else
	onlypick1_t=onlypick1_t-1
	if onlypick1_t<=0 then onlypick1_t=nil end
	end
	
	if c.sleep then
			top='You are asleep.'
	end
	if c.state=='Draft' then
			c.draft=1+combovalue()
			c.maxdraft=c.draft
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
					local y=136-32+card_ydist
					if c.combo then for j,w in ipairs(c.combo) do if w[2]==i then y=y-8; rect(x,y,27,32,15); break end end end
					if (not c.sleep) and coll(c.x,c.y,1,1, x,y,27,32) then
							--hover
								
							if btn(4) or left then 
									if sub(v,1,4)=='Plus' then
											if c.combo then for j,w in ipairs(c.combo) do if w[2]==i then goto skip end end end
											c.combo=c.combo or {}
											if #c.combo<1 then
											ins(c.combo,{v,i})
											table.sort(c.combo,function(a,b) return a[2]<b[2] end)
											else
											top='You can only pick 1 Plus card per turn.'
											onlypick1_t=100
											goto skip
											end
									else
									c.cardno=i
									end
									c.state=v
									sfx(4,12*3+5,12,2)
									::skip::
							end
							
							local col
							if FLASHSPD==0 then col=14
							else col=(t*FLASHSPD)%16 end
							rectb(x,y,27,32,col)
							print(v,x+2,y+14+8,col,false,1,true)
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
							if c.sleep then
									for i=1,7 do
									line(x,y+i,x+27-1,y+32-8+i,6)
									end
							end
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
	bg_t=bg_t+FLASHSPD
	else bg_t=0 end
end

function coll(x1,y1,w1,h1, x2,y2,w2,h2)
  return x1 < x2+w2 and
         x2 < x1+w1 and
         y1 < y2+h2 and
         y2 < y1+h1
end

function find(tbl,what)
		for i,v in ipairs(tbl) do if v==what then return i end end
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
-- 085:0000000000000000000900000009990000099999000999990009999900099999
-- 086:0000000000000000000000000000000000000000990000009999000099999000
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
-- 101:0009999900099999000999990009990000090000000000000000000000000000
-- 102:9999000099000000000000000000000000000000000000000000000000000000
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
-- 117:00000000000000000000000a000aa00a000aaaaa0000aaa00000aa0000aaa00a
-- 118:0000000000000000a0000000a00aa000aaaaa0000aaa000000aa0000a00aaa00
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
-- 133:00aaa00a0000aa000000aaa0000aaaaa000aa00a0000000a0000000000000000
-- 134:a00aaa0000aa00000aaa0000aaaaa000a00aa000a00000000000000000000000
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
-- 149:000000000000aa00000aaa0000aaaa000000aa000000aa0000aaaaa000000000
-- 150:0000000009999000099990000009900000999000000990000999900000000000
-- 152:00000bb00000bbbb000bbbbb000bbbbb000bbbb3000bbbb3000bbbb3000bbbb3
-- 153:00bbbbbb00bbbbbb00bbbbbb00bb2bbb00bb2bbb00bb2bbb00bb2bbb03bbbbbb
-- 154:bbbbb300bbbbb300bbbbb300b2bb3300b2bb3300b2bb330bb2bb33bbbbbb33bb
-- 155:0bbbb3000bbbb3000bbb33000bbb3300bbbb3300bbbb3300bbbb3300bbbb3000
-- 156:000bbbb3000bbbb3000bbbb3000bbbb3000bbbbb000bbbbb0000bbbb0000bbbb
-- 157:00bbbbbb00bbbbbb00bbbbbb00bbbbbb00b222bb30bb2bbbb3bbbbbbbbbbbbbb
-- 158:bbbbb300bbbbb300bbbbb300bbbb3300222b3300b2bb3300bbbb3300bbbb3300
-- 159:000000000000000000bbb00000bbbb0000bbbb000bbbbb000bbbb3000bbbb300
-- 161:00000000000000000000000a000000aa00000000000aa00000aa0a000aa00aaa
-- 162:0000000000000000aaaaa0000000aa00aa000aa00aa000aaaa0000aaa0000aa0
-- 163:0000000000000099000009000000090000999000090009000900090090000099
-- 164:0000000090000000090000000900000000999000090009000900090090000090
-- 165:0099990000999900000099000009990000009900009999000000000000000000
-- 166:aaaaa000aaaaa000000aa00000aa000000aa000000aa00000000000000000000
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
-- 181:000000000000000000000aaa00000aaa00000a0000000a0000000a0000000a00
-- 182:0000000000000000a0000000aaaaa0000aaaa0000000a0000000a0000000a000
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
-- 197:000aaa0000aaaa0000aaaa00000aa00000000000000000000000000000000000
-- 198:0000a0000000a00000aaa0000aaaa0000aaaa00000aa00000000000000000000
-- 200:eeeee000e000eee0000000ee0000000e000000ee00000ee30000ee33000ee633
-- 201:00000eee0000ee000000e0000000e000eeeee00033333ee0333333ee3336633e
-- 202:eee0000a000e0aaa0000aa33000aa333000a3333000aa3a3000a3a33000aa3a3
-- 203:a0000000a00aaaa03aaa333a3a33333aaa33333aa3a3a33aaa3a333aa3a3a33a
-- 204:eeeee000e000eee0000000ee0000000e000000ee00000ee30000ee33000ee333
-- 205:00000eee0000ee000000e0000000e000eeeee00033333ee0333333ee3333333e
-- 206:eee00000000ea000000aaaa000aaa3a00aaa333a0a3a3a330a33a3330a3a3a33
-- 207:0000000000000000000000000000000000000000a0000000a0aaaaa03aa333aa
-- 209:0000a090000a0900000a090000a0900000a09000000990000000099900000000
-- 210:00a00000000a0000000a00000000a0000000a000009900009900000000000000
-- 211:0aaaaa0000000009000000090000000000000000000000000000000000000000
-- 212:90000000000aaa0099000a00000a0000000aaa00000000000000000000000000
-- 213:0000000000090000000900000090009000900090009009000900090009000900
-- 214:000000000000000000a000000a0a00000a0aa000a00aa000a000aaa0a0aaaaa0
-- 216:000e6663000e666600093666000e33660009e333000093330000933300000933
-- 217:336663333666633336663333366333333333333e3333333e33333e9e3339e9e9
-- 218:e00a3a3ae00aa3aae000aa3ae000a33aeeee333aeeeeeea3ee333eaae33333ee
-- 219:3a3a333aa3a333a03a333aa03333aa0033aa0000aaa00000a000000000000000
-- 220:000e6333000e663300093663000e33660009e333000093330000933300000933
-- 221:333363333336633333663333366333333333333e3333333e33333e9e3339e9e9
-- 222:eaa3a33ae0aa3a3ae0aaa33ae00a33aaeeee33aaeeeeeea3ee333eaae33333ee
-- 223:aa3a333aa3a3a3333a3a333aa3a333aa3333aaa0aaaaa000a000000000000000
-- 225:0000000000000aaa00000a0000000a0000000a0000000a0000000a0000000a00
-- 226:00000000aaa00000000000000000000000a000000a0a0000a000a00000a00000
-- 227:0000000000000009000000090000000900000090000000900000099000009900
-- 228:0000000000000000900000009000000090000000900000000990000000999000
-- 229:0900090009000900009009000090009000900090000900000009000000000000
-- 230:a0aaaaa0a000aaa0a00aa0000a0aa0000a0a000000a000000000000000000000
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
-- 243:0999900000009990000000990000000900000009000000000000000000000000
-- 244:0009999009990000090000009900000090000000900000009000000000000000
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
-- 001:000000000000000000000000000000000000010001000100010001000100010001000000000000000000000000000000000000000000020002000200200000000000
-- 002:020002000200020002000200020002000200020002000200020002000200020002000200020002000100010001000100010001000000000000000200109000000000
-- 003:020002000200020002000200020002000200020001000200020002000200020000000200020002000200020001000100010001000100020001000100300000000000
-- 004:000001000200000001000200000001000200000001000200000001000200000001000200010001000100010001000100010000000100010001000100305000000000
-- 005:030003000300030003000300030003000300030003000300030003000300030003000300030003000300030003000300030003000300030003000300000000000000
-- 006:010002000200020002000200020002000200010001000000000000000000010001000100010002000100010001000000010000000100000001000000409000000000
-- 008:040004000400040004000400040004000400040004000400040004000400040004000400040004000400040004000400040004000400040004000400000000000000
-- 009:010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100000000000000
-- 010:020002000200020002000200020002000200020002000200020002000200020002000200020002000200020002000200020002000200020002000200000000000000
-- 011:150035005500650085009500b500c500e500f500f500f500f500f500f500f500f500f500f500f500f500f500f500f500f500f500f500f500f500f500409000000000
-- 012:050015002500350045005500550065007500750085009500a500a500b500c500c500d500e500f500f500f500f500f500f500f500f500f500f500f500000000000000
-- </SFX>

-- <PATTERNS>
-- 000:400088000000700088000000b00088000000e0008800000040008a000000000000000000022600000000000000000000044600000000000000000000066600000000000000000000000000000000000000000000000000000000000000000000400688000000700088000000b00088000000e0008800000040008a00000000000000000060008a00000040008a000000100000000000b00088000000000000000000100000000000b00088000000e00088000000900088000000100000000000
-- 001:900088000000000000000000000000000000500088000000700088000000000000000000022600000000000000000000044600000000000000000000066600000000000000000000000000000000000000000000000000000000000000000000900688000000000000000000400088000000000000100000400088000000700088000000900088000000e00086000000000000000000400088000000000000100000700088100000e00086000000b00086000000900086000000100080000000
-- 002:8881bc0000008000bc0000008000bc8000bc8000bc0000008000b60000000000000000008000bc0000008000bc0000008000bc0000008000bc0000008000bc8000bc8000bc0000008000b60000000000000000000000000000000000000000008000bc0000008000bc0000008000bc8000bc8000bc0000008000b60000000000000000008000bc0000008000bc0000008000bc0000008000bc0000008000bc8000bc8000bc0000008000b6000000000000000000000000000000000000000000
-- 003:400098000000b00096000000400098000000b00096100000b00096000000e00096000000400098000000700098000000b00098000000900098000000700098000000400098000000e00096000000b00096000000e00096000000400098000000400098000000b00096000000400098000000b00096000000900096000000b00096000000700096000000900096000000700096000000400096100000400096000000e00094000000400096000000e00094000000b00096000000e00096000000
-- 004:900096000000500096000000900096000000500096000000900096000000700096000000500096000000900096000000f00094100000f00094000000500096000000700096100000700096000000500096000000e00094000000b00094000000900094000000400096000000700096000000400096000000700096000000900096000000700096000000900096000000400096000000c00096000000e00096000000c00096000000700096000000e00096000000e00096000000400098000000
-- 005:400098000000e00096000000e00096000000900096000000900096000000e00096000000e00096000000700096000000b00096000000b00096000000700096000000b00096000000400096000000400096000000400096000000e00094000000e00096000000700098000000600098000000400098000000600098000000e00096000000900096000000e00096000000b00096000000900098000000700098000000900098000000e00098000000b00098000000900098000000e00098000000
-- 006:40009a00000040009a000000b0009800000040009a000000e00098000000e00098000000900098000000e00098000000b00098000000b00098000000b00098000000b00098000000900098000000b00098000000c00098000000b00098000000900098000000400098000000700098000000700098000000400098000000600098000000600098000000e00096000000400098000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 007:600088000000d00088000000b00088000000800088000000900088000000600088000000d00086000000600088000000000000000000d00088000000b0008800000080008800000040008a000000d0008800000060008a000000d00088000000600088000000d00088000000b00088000000800088000000900088000000600088000000d00086000000600088000000000000000000d00088000000b0008800000080008800000040008a000000d0008800000060008a000000d00088000000
-- 008:600098b00098d0009840009a800098b00098800098400098600098b00098d0009840009a60009ab00098900098400098600098b00098d0009840009a60009ab00098800098400098600098b00098d0009840009a60009ab00098900098400098600098b00098d0009840009a60009ab00098800098400098600098b00098d0009840009a60009ab00098900098400098600098b00098d0009840009a60009ab00098800098400098600098b00098d0009840009a60009ab00098900098400098
-- 009:500088000000c00088000000a00088000000700088000000800088000000500088000000c00086000000500088000000000000000000c00088000000a00088000000700088000000f00088000000c0008800000050008a000000c00088000000400088000000b00088000000900088000000600088000000700088000000400088000000b00086000000400088000000000000000000b00088000000900088000000600088000000e00088000000b0008800000040008a000000e00088000000
-- 010:500098a00098c00098f0009850009aa00098700098f00096500098a00098c00098f0009850009aa00098800098f00096500098a00098c00098f0009850009aa00098700098f00096500098a00098c00098f0009850009aa00098800098f00096400098900098b00098e0009840009a900098600098e00096400098900098b00098e0009840009a900098700098e00096400098900098b00098e0009840009a900098600098e00096400098900098b00098e0009840009a900098700098e00096
-- 011:50008a000000000000000000e0008800000050008a000000e0008800000090008a000000000000000000e0008800000040008a000000000000000000c0008800000040008a000000900088000000000000000000000000000000000000000000e00088000000c00088000000b00088000000000000000000e00088000000c00088000000b00088000000000000000000800088000000a00088000000b00088000000a00088000000d00088000000800088000000b00088000000a00088000000
-- 012:50008a000000000000000000e0008800000050008a000000e0008800000090008a000000000000000000e0008800000040008a000000000000000000c0008800000040008a000000900088000000000000000000000000000000000000000000e00088000000c00088000000b00088000000000000000000e00088000000c00088000000b00088000000000000000000900088000000b00088000000c00088000000b00088000000e00088000000b00088000000e0008800000040008a000000
-- 013:50009800000050009a00000050009800000050009a00000050009800000050009a00000090009800000090009a00000040009800000040009a00000040009800000040009a000000c00096000000c00098000000c00096000000c0009800000070009800000070009a00000070009800000070009a00000070009800000070009a00000080009800000080009a00000090009800000090009a00000090009800000090009a000000b00098000000b0009a000000e00098000000e0009a000000
-- 014:50009800000050009a00000050009800000050009a00000050009800000050009a00000090009800000090009a00000040009800000040009a00000040009800000040009a000000c00098000000c0009a000000c00098000000c0009a00000090009800000090009a00000070009800000070009a000000c00098000000c0009a000000e00098000000e0009a00000080009800000080009a000000b00098000000a0009a000000d00098000000d0009a000000b00098000000a0009a000000
-- 015:6881bc0000006000bc6103bc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 016:6881bc0000000000000000006000b80000000000000000006000bc0000000000000000006000bc0000006000bc6000bc6000b80000006000b80000000000000000000000000000006000bc6000bc6000b80000006000bc0000000000000000006881bc0000000000000000006000b80000000000000000006000bc0000000000000000006000bc0000006000bc6000bc6000b80000006000b80000000000000000000000000000006000bc6000bc6000b80000006000bc0000006000bc6000bc
-- 017:00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000040008a10000040008a100000e0008860008a70008a100000
-- 018:6881cc0000000000000000006000b80000000000000000006000bc0000000000000000006000bc0000006000bc6000bc6000b80000006000b80000000000000000000000000000006000bc6000bc6000b80000006000bc0000000000000000006881bc0000000000000000006000b80000000000000000006000bc0000000000000000006000bc0000006000bc6000bc6000b80000006000b80000000000000000000000000000006000bc6000bc6000b80000006000bc0000006000bc6000bc
-- 019:700088000000900088000000a00088000000900088000000c00088000000700088000000a00088000000900088010300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 020:70009800000070009a000000a0009800000090009a000000c00098000000c0009a000000a0009800000090009a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 021:6881b80000006000b80000000000000000000000000000006000bc6000bc6000b80000006000bc0000006000bc6000bc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 022:60008a00000000000000000040008a000000e0008800000040008a000000000000000000e0008a000000000000000000c0008a000000000000000000b0008a00000090008a000000b0008a00000000000000000000000000000000000010000090008a000000b0008a000000c0008a000000b0008a00000070008a00000060008a00000060008a00000070008a000000b0008a00000090008a00000070008a000000f0008800000040008a000000000000000000000000000000000000000000
-- 023:60008a00000000000000000040008a000000e0008800000040008a000000000000000000e0008a00000000000000000060008c000000000000000000b0008a00000090008a000000b0008a00000000000000000000000000000000000010000090008a000000b0008a000000c0008a000000b0008a00000070008a00000060008a00000060008a00000070008a000000b0008a00000090008a00000070008a000000f0008800000040008a000000000000000000000000000000000000000000
-- </PATTERNS>

-- <TRACKS>
-- 000:1010c02410c01010c02410c00810c02d10c0000000000000000000000000000000000000000000000000000000000000000000
-- 001:0000048420c4ac2044d830c4cc3044455085000000000000000000000000000000000000000000000000000000000000000000
-- </TRACKS>

-- <SCREEN>
-- 000:cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
-- 001:cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
-- 002:cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
-- 003:cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
-- 004:cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
-- 005:cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
-- 006:cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
-- 007:cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
-- 008:cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
-- 009:cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
-- 010:cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
-- 011:cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
-- 012:cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
-- 013:cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
-- 014:cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
-- 015:cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
-- 016:999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999
-- 017:999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999
-- 018:999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999
-- 019:999999999999911111111111111111111111111199999999999999999999999999911111111111111111111111111199999999999999999999999999911111111111111111111111111199999999999999999999999999911111111111111111111111111199999999999999999999999999911111111111
-- 020:99999999999991fffffffffffffffffffffffff19999999999999999999999999991fffffffffffffffffffffffff19999999999999999999999999991fffffffffffffffffffffffff19999999999999999999999999991fffffffffffffffffffffffff19999999999999999999999999991ffffffffff
-- 021:99999999999991fffffffffffffffffffff111111111111111999999999999999991fffffffffffffffffffffffff19999999999999999999999999991fffffffffffff1111111111ff19999999999999999999999999991fffffffffffffffffffffffff19999999999999999999999999991ffffffffff
-- 022:99999999999991ffffffffffffffffffff1444444444444444499999999999999991fffffffffffffffffffffffff19999999999999999999999999991ffffffffffff144444444444f19999999999999999999999999991fffffffffffffffffffffffff19999999999999999999999999991ffffffffff
-- 023:99999999999991ffffffffffffffffffff1444444444444444499999999999999991fffffffffffffffffffffffff19999999999999999999999999991ffffffffffff144444444444f19999999999999999999999999991fffffffffffffffffffffffff19999999999999999999999999991ffffffffff
-- 024:66666666666661ffffffffffffffffffff1444444444444444466666666666666661fffffffffffffffffffffffff16666666666666666666666666661ffffffffffff144444444444f16666666666666666666666666661fffffffffffffffffffffffff16666666666666666666666666661ffffffffff
-- 025:66666666666661ffffffff99ffffffffff1444444444444444466666666666666661ffffffffffffffaaaafffffff16666666666666666666666666661ffffffffffff144444444444f16666666666666666666666666661ffffffffffffffaaaafffffff16666666666666666666666666661fffffffaff
-- 026:66666666666661fffffff9999fffff1111144444444444444411111666666666611111111111111111111affff11111111111111111111666666666661fff111111111144444444444f16666666666666666666666666661fffffffffffffafffafffffff16666666666666666666666666661fffffffaaf
-- 027:66666666666661ffffff999999fff144444444444444444444444444666666661444444444444444444444fff144444444444444444444466666666661ff1444444444444444444444f16666666666666666666666666661ffffffffffffaffffafffffff16666666666666666666666666661fffffffaaa
-- 028:66666666666661ffffff999999fff144444444444666666661444444666666661444444444444444444444fff144444444444444444444466666666661ff1444444444444444444444f16666666666666666666666666661fffffffffffafffffafffffff16666666666666666666666666661fffffffafa
-- 029:66666666666661fffffff9999ffff144444444444666666661444444666666661444444444444444444444fff144444444444444444444466666666661ff1444444444444444444444f16666666666666666666666666661ffffffffffafffffaffffffff16666666666666666666666666661fffffffaff
-- 030:66666666666661ffffffff99fffff144444444444666666661444444666666661444444444444444444444fff144444444444444444444466666666661ff1444444444444444444444f16666666666666666666666666661ffffff9ffafffffafffffffff16666666666666666666666666661fffffffaff
-- 031:66666666666661ffffffffffffff9144444444444666666661444444666611111444444444444444444444fff144444444444444444444111116666611111444444444444444444444f16666666666666666666666666661ffffff99affaffaffffffffff16666666666666666666666666661fffffffaff
-- 032:66666666999991fffffffffffff99144444444444ccccccccc44444cccc144444444444444444444444444fff144444444444444444444444444ccc144444444444444444444444444f1ccccccccccccccccccccccccccc1fffffff99faffafffffffffff1cccccccccccccccccccccc999991fffffffaff
-- 033:66666666999991ffffffffffff999144444444444cccccccccccccccccc1444444c1ffffff144444444444fff144444444444cccccccc1444444ccc1444444fffffff9144444444444f1ccccccccccccccccccccccccccc1ffffffff99ffaffffffffffff1cccccccccccccccccccccc999991fffffffaaf
-- 034:66666666999991ffffffffffff999144444444444cccccccccccccccccc1444444c1ffffff144444444444fff144444444444cccccccc1444444ccc1444444ffffffff144444444444f1ccccccccccccccccccccccccccc1fffffff9999afffffffffffff1cccccccccccccccccccccc999991ffffffffaa
-- 035:66666666999991fffffffffffff99144444444444cccccccccccccccccc1444444c1ffffff144444444444fff144444444444cccccccc1444444ccc1444444ffffffff144444444444f1ccccccccccccccccccccccccccc1ffffff999f99fffffffffffff1cccccccccccccccccccccc999991fffffffffa
-- 036:66666666999991ffffffffffffff9144444444444ccccccccc11111cccc1444444c1fffff9144444444444fff144444444444cccccccc1444444ccc1444444ffffffff144444444444f1ccccccccccccccccccccccccccc1fffff999fff99ffffffffffff1cccccccccccccccccccccc999991ffffffffff
-- 037:66666666999991fffffffffffffff144444444444cccccccc1444444ccc1444444c1ffffff144444444444fff144444444444ccccccccc44444cccc1444444ffffffff144444444444f1ccccccccccccccccccccccccccc1ffffff9ffffffffffffffffff1cccccccccccccccccccccc999991ffffffffff
-- 038:66666666999991fffffffffffffff144444444444cccccccc1444444ccc1444444c1ffffff144444444444fff144444444444cccccccccccccccccc1444444ffffffff144444444444f1ccccccccccccccccccccccccccc1fffffffffffffffffffffffff1cccccccccccccccccccccc999991ffffffffff
-- 039:66666666999991fffffffffffffff144444444444cccccccc1444444ccc1444444c1ffffff144444444444fff144444444444cccccccccccccccccc1444444ffffffff144444444444f1ccccccccccccccccccccccccccc1fffffffffffffffffffffffff1cccccccccccccccccccccc999991ffffffffff
-- 040:66666666999991fffffffffffffff144444444444cccccccc1444444ccc1444444c1ffffff144444444444fff144444444444cccccccccccccccccc1444444ffffffff144444444444f1ccccccccccccccccccccccccccc1fffffffffffffffffffffffff1cccccccccccccccccccccc999991ffffffffff
-- 041:66666666999991fffffffffffffff144444444441111111111444444ccc144444111111111144444444444fff144444444444cccccccccccccccccc144444111111111144444444444f1ccccccccccccccccccccccccccc1fffffffffffffffffffffffff1cccccccccccccccccccccc999991ffffffffff
-- 042:66666666999991ffffffffffffffff4444444444444444444444444ccccc44444444444444444444444444fff144444444444ccccccccccccccccccc44444444444444444444444444f1ccccccccccccccccccccccccccc1fffffffffffffffffffffffff1cccccccccccccccccccccc999991ffffffffff
-- 043:66666666999991ffffffffffffffffffff14444444444444444ccccccccccccc1444444444444444444444fff144444444444cccccccccccccccccccc1ff1444444444444444444444f1ccccccccccccccccccccccccccc1fffffffffffffffffffffffff1cccccccccccccccccccccc999991ffffffffff
-- 044:66666666999991ffffffffffffffffffff14444444444444444ccccccccccccc1444444444444444444444fff144444444444cccccccccccccccccccc1ff1444444444444444444444f1ccccccccccccccccccccccccccc1fffffffffffffffffffffffff1cccccccccccccccccccccc999991ffffffffff
-- 045:66666666999991ffffffffffffffffffff14444444444444444ccccccccccccc1444444444444444444444fff144444444444cccccccccccccccccccc1ff1444444444444444444444f1ccccccccccccccccccccccccccc1fffffffffffffffffffffffff1cccccccccccccccccccccc999991ffffffffff
-- 046:66666666999991ffffffffffffffffffff14444444444444444ccccccccccccc1444444444444444444444fff144444444444cccccccccccccccccccc1ff1444444444444444444444f1ccccccccccccccccccccccccccc1fffffffffffffffffffffffff1cccccccccccccccccccccc999991ffffffffff
-- 047:66666666999991fffffffffffffffffffff444444444444444ccccccccccccccc44444444444444444444fffff4444444444ccccccccccccccccccccc1fff44444444444444444444ff1ccccccccccccccccccccccccccc1fffffffffffffffffffffffff1cccccccccccccccccccccc999991ffffffffff
-- 048:66666666999991fffffffffffffffffffffffff1ccccccccccccccccccccccccccc1fffffffffffffffffffffffff1ccccccccccccccccccccccccccc1fffffffffffffffffffffffff1ccccccccccccccccccccccccccc1fffffffffffffffffffffffff1cccccccccccccccccccccc999991ffffffffff
-- 049:66666666999991fffffffffffffffffffffffff1ccccccccccccccccccccccccccc1fffffffffffffffffffffffff1ccccccccccccccccccccccccccc1fffffffffffffffffffffffff1ccccccccccccccccccccccccccc1fffffffffffffffffffffffff1cccccccccccccccccccccc999991ffffffffff
-- 050:6666666699999111111111111111111111111111ccccccccccccccccccccccccccc111111111111111111111111111ccccccccccccccccccccccccccc111111111111111111111111111ccccccccccccccccccccccccccc111111111111111111111111111cccccccccccccccccccccc9999911111111111
-- 051:1111111111111999cccccccccccccccccccccccc111111111111111111111111111cccccc111111111111ccccccccc111111111111111111111111111ccccccccccccccccccccccccccc111111111111111111111111111ccccccccccccccccccccccccccc11111111111111111111111111199966666666
-- 052:ffffffffffff1999cccccccccccccccccccccccc1fffffffffffffffffffffffff1ccccc14444444444444cccccccc1fffffffffffffffffffffffff1ccccccccccccccccccccccccccc1fffffffffffffffffffffffff1ccccccccccccccccccccccccccc1fffffffffffffffffffffffff199966666666
-- 053:ffffffffffff1999cccccccccccccccccccccccc1fffffffffffffffffffffffff1ccccc14444444444444cccccccc1fffffffffffffffffffffffff1ccccccccccccccccccccccccccc1fffffffffffffffffffffffff1ccccccccccccccccccccccccccc1fffffffffffffffffffffffff199966666666
-- 054:ffffffffffff1999cccccccccccccccccccccccc1fffffffffffffffffffffffff1ccc1114444444444444cc111111111111fffffffff111111111111ccc111111111111ccccccccc111111111fffffffff111111111ff1ccc111111111111ccccccccc111111111111fffffffffffffffff199966666666
-- 055:ffffffffffff1999cccccccccccccccccccccccc1fffffffffffffffffffffffff1cc1444444444444444cc14444444444444fffffff14444444444444c14444444444444ccccccc14444444444fffffff14444444444f1cc14444444444444ccccccc14444444444444ffffffffffffffff199966666666
-- 056:ffffffffffff1999cccccccccccccccccccccccc1fffffffffff99ffffffffffff1cc14444444cccccccccc14444444444444fffffff14444444444444c14444444444444ccccccc14444444444fffffff14444444444f1cc14444444444444ccccccc14444444444444ffffffffffffffff199966666666
-- 057:ffffffffffff1999cccccccccccccccccccccccc1ffffffffff9999fffffffffff1cc14444444cc111111cc1444444444444111aaf1114444444444444c1444444444444111ccc111444444444111fff111444444444111cc1444444444444111ccc11144444444444449fffffffffffffff199966666666
-- 058:ffffffffffff1999cccccccccccccccccccccccc1fffffffff999999ffffffffff1cc14444444c14444444c14444444444444444a14444444444444444c14444444444444444c14444444444444444f14444444444444444c14444444444444444c1444444444444444999ffffffffffffff199966666666
-- 059:ffffffffffff1999cccccccccccccccccccccccc1fffffffff999999ffffffffff1cc14444444c14444444c14444444ffff14444a14444ffff14444444c14444444cccc14444c14444cc1f14444444a14444444f14444444c14444444cccc14444c14444444444fff999999fffffffffffff199966666666
-- 060:ffffffffffff1999cccccccccccccccccccccccc1ffffffffff9999fffffffffff1cc14444444c14444444c14444444ffff14444a14444ffff14444444c14444444cccc14444c14441111114444444f14444441114444444c14444444cccc14444c14444444441111119999fffffffffffff199966666666
-- 061:9fffffffffff1999cccccccccccccccccccccccc1fffffffffff99ffffffffffff1cc14444444cc4444444c14444444fffff444af14444ffff14444444c14444444cccc14444c14444444444444444f1444444444444444cc14444444ccccc444ccc444444444444444499ffffffffffffff199966666666
-- 062:99ffffffffff1999cccccccccccccccccccccccc1fffffffffffffffffffffffff1cc14444444cccc14444c14444444fffffafffa14444ffff14444444c14444444cccc14444c14444444444444444f14444444444ffff1cc14444444cccccccccccccccc144444444449fffffffffffffff199966666666
-- 063:99ffffffffff1999cccccccccccccccccccccccc1fffffff99ffffff99ffffffff1cc14444441111114444c14444444fffffaaaaa14441111114444444c14444444cccc14444c14444444444444444a1444444444111ff1cc14444444ccccccccccc1111114444444444fffff99fffffffff199966666666
-- 064:9fffffffffff1999cccccccccccccccccccccccc1ffffff9999ffff9999fffffff1ccc4444444444444444c14444444fffffffffff4444444444444444c14444444cccc14444cc4444444444444444af4444444444444f1cc14444444cccccccccc1444444444444444fffff9999ffffffff199966666666
-- 065:ffffffffffff1999cccccccccccccccccccccccc1fffff999999ff999999ffffff1ccccc14444444444444c14444444fffffffffff9914444444444444c14444444cccc14444cccccccc1f14444444ffff14444444444f1cc14444444cccccccccc14444444444444ffffff999999fffffff199966666666
-- 066:ffffffffffff1999cccccccccccccccccccccccc1fffff999999ff999999ffffff1ccccc14444444444444c14444444fffffffffffff14444444444444c14444444cccc14444ccccc1111114444444ffff14444444444f1cc14444444cccccccccc14444444444444ffffff999999fffffff199966666666
-- 067:ffffffffffff1999cccccccccccccccccccccccc1ffffff9999ffff9999fffffff1cccccc444444444444ccc4444441ffffffffffffff444444444444ccc444444cccccc444ccccc1444444444444ffffff444444444ff1ccc444444cccccccccccc444444444444ffffffff9999ffffffff199966666666
-- 068:ffffffffffff1999cccccccccccccccccccccccc1fffffff99ffffff99ffffffff1ccccccccccccccccccccccccccc1fffffffffffffffffffffffff1ccccccccccccccccccccccc14444444444faaaaaaaaaaffffffff1ccccccccccccccccccccccccccc1ffffffffffffff99fffffffff199966666666
-- 069:ffffffffffff1999cccccccccccccccccccccccc1fffffffffffffffffffffffff1ccccccccccccccccccccccccccc1fffffffffffffffffffffffff1ccccccccccccccccccccccc14444444444fffffffffffffffffff1ccccccccccccccccccccccccccc1fffffffffffffffffffffffff199966666666
-- 070:ffffffffffff1999cccccccccccccccccccccccc1fffffffffffffffffffffffff1ccccccccccccccccccccccccccc1fffffffffffffffffffffffff1cccccccccccccccccccccccc444444444ffffffffffffffffffff1ccccccccccccccccccccccccccc1fffffffffffffffffffffffff199966666666
-- 071:ffffffffffff1999cccccccccccccccccccccccc1fffffffffffffffffff22222222cccccccccccccccc2222cccccc1fffffffffffffffffffffffff1ccccccccccccccccccccccccccc1fffffffffffffffffffffffff1ccccccccccccccccccccccccccc1fffffffffffffffffffffffff199966666666
-- 072:ffffffffffff1999cccccccccccccccccccccccc1ffffffffffffffffff2111111112cccccccccccccc211112ccccc1fffffffffffffffffffffffff1ccccccccccccccccccccccccccc1fffffffffffffffffffffffff1ccccccccccccccccccccccccccc1fffffffffffffffffffffffff199966666666
-- 073:ffffffffffff1999cccccccccccccccccccccccc1ffffffffffffffffff21111111122cccc222222ccc211112ccccc2222ffff22ff2222ff2222ffff222222cccccccccccccccccccccc1fffffffffffffffffffffffff1ccccccccccccccccccccccccccc1fffffffffffffffffffffffff199966666666
-- 074:ffffffffffff1999cccccccccccccccccccccccc1ffffffffffffffffff211112222112cc21111112cc211112cccc211112ff2112211112211112ff21111112ccccccccccccccccccccc1fffffffffffffffffffffffff1ccccccccccccccccccccccccccc1fffffffffffffffffffffffff199966666666
-- 075:ffffffffffff1999cccccccccccccccccccccccc1ffffffffffffffffff211112f12112c2211111122c211112cccc211112ff2112211112211112f2211111122cccccccccccccccccccc1fffffffffffffffffffffffff1ccccccccccccccccccccccccccc1fffffffffffffffffffffffff199966666666
-- 076:ffffffffffff1999cccccccccccccccccccccccc1ffffffffffffffffff211112f12112211112211112211112cccc211112ff2112f2211111122f211112211112ccccccccccccccccccc1fffffffffffffffffffffffff1ccccccccccccccccccccccccccc1fffffffffffffffffffffffff199966666666
-- 077:ffffffffffff1999cccccccccccccccccccccccc1ffffffffffffffffff211112f12112211112211112211112cccc211112ff2112ff21111112ff211112211112ccccccccccccccccccc1fffffffffffffffffffffffff1ccccccccccccccccccccccccccc1fffffffffffffffffffffffff199966666666
-- 078:ffffffffffff1999cccccccccccccccccccccccc1ffffffffffffffffff211112f1211221111112222c211112cccc211112ff2112ff21111112ff21111112222cccccccccccccccccccc1fffffffffffffffffffffffff1ccccccccccccccccccccccccccc1fffffffffffffffffffffffff199966666666
-- 079:ffffffffffff1999cccccccccccccccccccccccc1ffffffffffffffffff211112222112211111122ccc211112222c211112222112f2211111122f211111122cccccccccccccccccccccc1fffffffffffffffffffffffff1ccccccccccccccccccccccccccc1fffffffffffffffffffffffff199966666666
-- 080:ffffffffffff16666666666666666666666666661ffffffffffffffffff211111111226622111111266622111111262211111122f211112211112f2211111126666666666666666666661fffffffffffffffffffffffff16666666666666666666666666661fffffffffffffffffffffffff166666666666
-- 081:ffffffffffff16666666666666666666666666661ffffffffffffffffff21111111126666211111126666211111126121111112ff211112211112ff211111126666666666666666666661fffffffffffffffffffffffff16666666666666666666666666661fffffffffffffffffffffffff166666666666
-- 082:111111111111166666666666666666666666666611111111111111111111222222226666662222226666662222226611222222111122221122221111222222666666666666666666666611111111111111111111111111166666666666666666666666666611111111111111111111111111166666666666
-- 083:666666666666611111111111111111111111111166666666666666666666666666611111111111111111111111111166666666666666666666666666611111111111111111111111111166666666666666666666666666611111111111111111111111111166666666666666666666666666611111111111
-- 084:66666666666661fffffffffffffffffffffffff16666666666666666666666666661fffffffffffffffffffffffff16666666666666666666666666661fffffffffffffffffffffffff16666666666666666666666666661fffffffffffffffffffffffff16666666666666666666666666661ffffffffff
-- 085:66666666666661fffffffffffffffffffffffff16666666666666666666666666661fffffffffffffffffffffffff16666666666666666666666666661fffffffffffffffffffffffff16666666666666666666666666661fffffffffffffffffffffffff16666666666666666666666666661ffffffffff
-- 086:66666666666661fffffffffffffffffffffffff16666666666666666666666666661fffffffffffffffffffffffff16666666666666666666666666661fffffffffffffffffffffffff16666666666666666666666666661fffffffffffffffffffffffff16666666666666666666666666661ffffffffff
-- 087:66666666666661fffffffffffffffffffffffff16666666666666666666666666661fffffffffffffffffffffffff16666666666666666666666666661fffffffffffffffffffffffff16666666666666666666666666661fffffffffffffffffffffffff16666666666666666666666666661ffffffffff
-- 088:99999999999991ffffffffffffff9ffffffffff19999999999999999999999999991fffffffffffffffffffffffff19999999999999999999999999991fffffffffaaaaaaffffffffff19999999999999999999999999991ffffffffff999ffffffffffff19999999999999999999999999991ffffffffff
-- 089:99999999999991fffffffffffff99ffffffffff19999999999999999999999999991fffffffffffffffffffffffff19999999999999999999999999991fffffffffafffffffffffffff19999999999999999999999999991fffffffff9fff9fffffffffff19999999999999999999999999991ffffffffff
-- 090:99999999999991fffffff99fff999ffffffffff19999999999999999999999999991fffffffffffffffffffffffff19999999999999999999999999991fffffffffafffffffffffffff19999999999999999999999999991fffffffff9fff9fffffffffff19999999999999999999999999991fffffffff9
-- 091:99999999999991fffffff999ff999ffffffffff19999999999999999999999999991fffffffffffffffffffffffff19999999999999999999999999991fffffffffaffffaffffffffff19999999999999999999999999991ffffff999fffff999ffffffff19999999999999999999999999991fffffffff9
-- 092:99999999999991ffffffff9999999ffffffffff19999999999999999999999999991fffffffffff99ffffffffffff19999999999999999999999999991fffffffffafffafafffffffff19999999999999999999999999991fffff9fff9fff9fff9fffffff19999999999999999999999999991ffffffffff
-- 093:99999999999991ffffffff9999f9999999fffff19999999999999999999999999991ffffffffff9999fffffffffff19999999999999999999999999991fffffffffaffafffaffffffff19999999999999999999999999991fffff9fff9fff9fff9fffffff19999999999999999999999999991ffffffffff
-- 094:99999999999991fffffff9999ff99f99fffffff19999999999999999999999999991fffffffff999999ffffffffff19999999999999999999999999991fffffffffaffffaffffffffff19999999999999999999999999991ffff9fffff999fffff9ffffff19999999999999999999999999991ffffffffff
-- 095:99999999999991ffffff9999ffffff9ffffffff19999999999999999999999999991fffffffff999999ffffffffff19999999999999999999999999991fffffffffaffffaffffffffff19999999999999999999999999991fffff9fff9fff9fff9fffffff19999999999999999999999999991fffffff99f
-- 096:ccccccccccccc1fffff999ffffff999ffffffff1ccccccccccccccccccccccccccc1ffffffffff9999fffffffffff1ccccccccccccccccccccccccccc1fffffffafffaffaffffffffff1ccccccccccccccccccccccccccc1fffff9fff9fff9fff9fffffff1ccccccccccccccccccccccccccc1ffffff9999
-- 097:ccccccccccccc1ffff9999f99fff9999fffffff1ccccccccccccccccccccccccccc1fffffffffff99ffffffffffff1ccccccccccccccccccccccccccc1ffffffffafafffaffffffffff1ccccccccccccccccccccccccccc1ffffff999fffff999ffffffff1ccccccccccccccccccccccccccc1fffff99999
-- 098:ccccccccccccc1ffff99f999fffff999fffffff1ccccccccccccccccccccccccccc1fffffffffffffffffffffffff1ccccccccccccccccccccccccccc1fffffffffaffffaffffffffff1ccccccccccccccccccccccccccc1fffffffff9fff9fffffffffff1ccccccccccccccccccccccccccc1fffff99999
-- 099:ccccccccccccc1fffffff999f999f9999ffffff1ccccccccccccccccccccccccccc1fffffffffffffffffffffffff1ccccccccccccccccccccccccccc1ffffffffffffffaffffffffff1ccccccccccccccccccccccccccc1fffffffff9fff9fffffffffff1ccccccccccccccccccccccccccc1ffffff9999
-- 100:ccccccccccccc1fffffff99f99999f999ffffff1ccccccccccccccccccccccccccc1fffffffffffffffffffffffff1ccccccccccccccccccccccccccc1ffffffffffffffaffffffffff1ccccccccccccccccccccccccccc1ffffffffff999ffffffffffff1ccccccccccccccccccccccccccc1fffffff99f
-- 101:ccccccccccccc1fffffff9fff99ffffffffffff1ccccccccccccccccccccccccccc1fffffffffffffffffffffffff1ccccccccccccccccccccccccccc1fffffffffaaaaaaffffffffff1ccccccccccccccccccccccccccc1fffffffffffffffffffffffff1ccccccccccccccccccccccccccc1ffffffffff
-- 102:ccccccccccccc1fffffffffff9fffffffffffff1ccccccccccccccccccccccccccc1fffffffffffffffffffffffff1ccccccccccccccccccccccccccc1fffffffffffffffffffffffff1ccccccccccccccccccccccccccc1fffffffffffffffffffffffff1ccccccccccccccccccccccccccc1ffffffffff
-- 103:ccccccccccccc1fffffffffffffffffffffffff1ccccccccccccccccccccccccccc1fffffffffffffffffffffffff1ccccccccccccccccccccccccccc1fffffffffffffffffffffffff1ccccccccccccccccccccccccccc1fffffffffffffffffffffffff1ccccccccccccccccccccccccccc1ffffffffff
-- 104:ffffffffffff111111111111111111111111111111111111111111111111111111111111111111111111111111111fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 105:ffffffffffff1fffffffffffffffffffffffff11fffffffffffffffffffffffff11fffffffffffffffffffffffff1fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 106:ffffffffffff1fffffffffffffffffffffffff11fffffffffffffffffffffffff11fffffffffffffffffffffffff1fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 107:ffffffffffff1fffffffffffffffffffffffff11fffffffffffffffffffffffff11fffffffffffffffffffffffff1fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 108:ffffffffffff1fffffffffffffffffffffffff11fffffffffffffffffffffffff11fffffffffffffffffffffffff1fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 109:ffffffffffff1fffffffffffffffffffffffff11fffffffffffffffffffffffff11ffffffffaafff9999ffffffff1ffffffffffff0f0ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 110:ffffffffffff1fffffff9fffffffffffffffff11fffffffffffaaffffffffffff11fffffffaaafff9999ffffffff1ffffffffffff0ff0fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 111:ffffffffffff1fffffff999fffffffffffffff11fffffffaaffaaffaaffffffff11ffffffaaaafffff99ffffffff1ffffffffffff0ff0fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 112:ffffffffffff1fffffff99999fffffffffffff11fffffffaaaaaaaaaaffffffff11ffffffffaaffff999ffffffff1ffffffffffff0fff0ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 113:ffffffffffff1fffffff9999999fffffffffff11ffffffffaaaffaaafffffffff11ffffffffaafffff99ffffffff1ffffffffffff0fff0ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 114:ffffffffffff1fffffff999999999fffffffff11ffffffffaaffffaafffffffff11ffffffaaaaaff9999ffffffff1ffffffffffff0ffff0fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 115:ffffffffffff1fffffff9999999999ffffffff11ffffffaaaffaaffaaafffffff11fffffffffffffffffffffffff1ffffffffffff0ffff0fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 116:ffffffffffff1fffffff999999999fffffffff11ffffffaaaffaaffaaafffffff11ffffff9999ffaaaaaffffffff1ffffffffffff0fffff0ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 117:ffffffffffff1fffffff9999999fffffffffff11ffffffffaaffffaafffffffff11ffffff9999ffaaaaaffffffff1ffffffffffff0fffff0ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 118:ffffffffffff1fffffff99999fffffffffffff11ffffffffaaaffaaafffffffff11ffffffff99fffffaaffffffff1ffffffffffff0ffffff0fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 119:ffffffffffff1fffffff999fffffffffffffff11fffffffaaaaaaaaaaffffffff11fffffff999ffffaafffffffff1ffffffffffff0ffffff0fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 120:ffffffffffff1fffffff9fffffffffffffffff11fffffffaaffaaffaaffffffff11ffffffff99ffffaafffffffff1ffffffffffff0fffffff0ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 121:ffffffffffff1fffffffffffffffffffffffff11fffffffffffaaffffffffffff11ffffff9999ffffaafffffffff1ffffffffffff0ff0ff00fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 122:ffffffffffff1fffffffffffffffffffffffff11fffffffffffffffffffffffff11fffffffffffffffffffffffff1ffffffffffff0f00ff0ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 123:ffffffffffff1fffffffffffffffffffffffff11fffffffffffffffffffffffff11fffffffffffffffffffffffff1fffffffffffff0ff0ff0fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 124:ffffffffffff1fffffffffffffffffffffffff11fffffffffffffffffffffffff11fffffffffffffffffffffffff1ffffffffffffffff0ff0fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 125:ffffffffffff1fffffffffffffffffffffffff11fffffffffffffffffffffffff11fffffffffffffffffffffffff1fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 126:ffffffffffff1f11ff11ffffffffffffffffff11ff1fffffff1ff1fffffffffff11ff11fffffffffff1fffffffff1fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 127:ffffffffffff1f1f1ff1ff11ff1f1fffffffff11f1f1f11ff111ffff1ff11ffff11f1fff1f1ff11ff11ff11fffff1fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 128:ffffffffffff1f11fff1fff11f1f1fffffffff11f1f1f1f1ff1ff1f1f1f1f1fff11f1fff11ff1f1f1f1f11ffffff1fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 129:ffffffffffff1f1ffff1ff1f1ff11fffffffff11f1f1f1f1ff1ff1f1f1f1f1fff11f1fff1fff11ff1f1fff1fffff1fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 130:ffffffffffff1f1fff111f111fff1fffffffff11ff1ff11ffff1f1ff1ff1f1fff11ff11f1ffff11ff11f11ffffff1fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 131:ffffffffffff1ffffffffffffff1ffffffffff11fffff1fffffffffffffffffff11fffffffffffffffffffffffff1fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 132:ffffffffffff1fffffffffffffffffffffffff11fffffffffffffffffffffffff11fffffffffffffffffffffffff1fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 133:ffffffffffff1fffffffffffffffffffffffff11fffffffffffffffffffffffff11fffffffffffffffffffffffff1fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 134:ffffffffffff1fffffffffffffffffffffffff11fffffffffffffffffffffffff11fffffffffffffffffffffffff1fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 135:ffffffffffff111111111111111111111111111111111111111111111111111111111111111111111111111111111fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- </SCREEN>

-- <PALETTE>
-- 000:140c1c44243430346d4e4a4e854c30346524d04648757161597dced27d2c8595a16daa2cd2aa996dc2cadad45edeeed6
-- </PALETTE>


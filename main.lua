SpriteSheet = require("spriteSheet");
EnemySpriteSheet = require("enemySpriteSheet");
require("menu");
require("TEsound");

function love.load()
	CurrentState = "menu";
	LoadBgElements();
	LoadActionAssets();
	CreateHero();
	CreateEnemy();
	CreateHealthBar();
	LoadSoundAssets();
	GroundHeight = Background:getHeight() - HeroSS:getWidth()/5 - GroundLevel:getHeight();
	MouseX = 0;
	MouseY = 0;
	ConstantRandom = math.random(1,2);
end

GameStates = {}
function GameStates.game(dt)
	LoopBGmusic();
	ChangeHeroAnimation(dt);
	--HeroActions(dt);
	HeroActionsMouse(dt);
	HeroJumpPhysics(dt);
	IdlePostJump();
	HeroCooldown(dt);
	GetEnergyLevel(dt);
	SpawnEnemies(dt);
	UpdateEnemies(dt);
	HeroAttackCollision(dt);
	RemoveEnemy(dt);
	Time = Time + dt;
end

function GameStates.menu()
	Menu.update(dt);
end

DrawStates = {}
function DrawStates.game()
	--Background and Hero and Enemies
	love.graphics.draw(Background);
	love.graphics.draw(GroundLevel, 0, (love.graphics.getHeight()-GroundLevel:getHeight()));
	DrawEnemies();
	love.graphics.draw(Hero.image, HeroFrames[Hero.currentFrame], Hero.xPosition, Hero.yPosition);
	love.graphics.draw(Health.image, HealthFrames[CurrentHealth]);
--Player Movements/Actions
	love.graphics.draw(LeftMovement, 0, GroundHeight+HeroSS:getWidth()/5);
	love.graphics.draw(RightMovement, RightMovement:getWidth()*2.5, GroundHeight+HeroSS:getWidth()/5);
	love.graphics.draw(Jump, Background:getWidth() - Jump:getWidth()*3.5, Background:getHeight() - Jump:getHeight());
	love.graphics.draw(Attack, Background:getWidth() - Jump:getWidth()*1, Background:getHeight() - Jump:getHeight())	
	
	love.graphics.print(Score);
	love.graphics.print(DeathDelay,100);
end

function DrawStates.menu()
	Menu.drawBG();
	Menu.drawPlay();
end

function love.update(dt)
	GameStates[CurrentState](dt);
end

function love.draw()
	DrawStates[CurrentState]();
end

--FUNCTIONS--
	--Load--
function LoadBgElements()
	Background = love.graphics.newImage("Bg.png");
	GroundLevel = love.graphics.newImage("BgGroundLevel.png");	
	Score = 0;
	Time = 0;
end

function LoadActionAssets()
	RightMovement = love.graphics.newImage("Right.png");
	LeftMovement = love.graphics.newImage("Left.png");
	Jump = love.graphics.newImage("Jump.png");
	Attack = love.graphics.newImage("Attack.png");
end

function LoadSoundAssets()
	AttackSounds = {"Attack2.wav", "Attack3.wav", "PhaseBladeSwing.wav"};
	JumpSounds = {"Jump1.wav", "Jump2.wav"};	
	BGmusic1 = love.audio.newSource('NikesInstrumental.mp3');
	BGmusic2 = love.audio.newSource('StarboyInstrumental.wav');
    BGmusic1:play()
end

function LoopBGmusic()
	if BGmusic1:isStopped() then
		BGmusic2:play();
	elseif BGmusic2:isStopped() then
		BGmusic1:play();
	end
end

function CreateEnemy()
	Enemies={};
	EnemyTimer = 0;
	DeathDelay = 0;
	EnemyStopped = false;
	EnemySS = love.graphics.newImage("EnemySS.png");
end

function CreateHealthBar()
	HealthSS = love.graphics.newImage("HealthSS.png");
	Health = SpriteSheet:new(HealthSS, HealthSS:getWidth()/3, HealthSS:getHeight());
	CurrentHealth = 1;
	HealthFrames = 
	{
		love.graphics.newQuad(0, 0, Health.frameWidth, Health.frameHeight, Health.image:getWidth(), Health.image:getHeight()),
		love.graphics.newQuad(0, 0, Health.frameWidth*2, Health.frameHeight, Health.image:getWidth(), Health.image:getHeight()),
		love.graphics.newQuad(0, 0, Health.frameWidth*3, Health.frameHeight, Health.image:getWidth(), Health.image:getHeight())	
	}
end

function CreateHero()	
	HeroSS = love.graphics.newImage("HeroFullSS2.png");
	Hero = SpriteSheet:new(HeroSS, HeroSS:getWidth()/5, HeroSS:getWidth()/5);
	HeroFrameMax = 5;
	HeroFrameMin = 1;
	JumpTimer = 0;
	ATKcooldown = 0;
	FacingLeft = false; --Checks which direction player is facing
	IsAttacking = false;
	HeroFrames = 
	{
		love.graphics.newQuad(0, 0, Hero.frameWidth, Hero.frameHeight, Hero.image:getWidth(), Hero.image:getHeight()), --Idling Right
        love.graphics.newQuad(Hero.frameWidth, 0, Hero.frameWidth, Hero.frameHeight, Hero.image:getWidth(), Hero.image:getHeight()),
        love.graphics.newQuad(Hero.frameWidth * 2, 0, Hero.frameWidth, Hero.frameHeight, Hero.image:getWidth(), Hero.image:getHeight()),
		love.graphics.newQuad(Hero.frameWidth * 3, 0, Hero.frameWidth, Hero.frameHeight, Hero.image:getWidth(), Hero.image:getHeight()),
		love.graphics.newQuad(Hero.frameWidth * 4, 0, Hero.frameWidth, Hero.frameHeight, Hero.image:getWidth(), Hero.image:getHeight()),
		love.graphics.newQuad(0, Hero.frameWidth*1, Hero.frameWidth, Hero.frameHeight, Hero.image:getWidth(), Hero.image:getHeight()), --Walking Right
        love.graphics.newQuad(Hero.frameWidth, Hero.frameWidth, Hero.frameWidth, Hero.frameHeight, Hero.image:getWidth(), Hero.image:getHeight()),
        love.graphics.newQuad(Hero.frameWidth * 2, Hero.frameWidth, Hero.frameWidth, Hero.frameHeight, Hero.image:getWidth(), Hero.image:getHeight()),
		love.graphics.newQuad(Hero.frameWidth * 3, Hero.frameWidth, Hero.frameWidth, Hero.frameHeight, Hero.image:getWidth(), Hero.image:getHeight()),
		love.graphics.newQuad(Hero.frameWidth * 4, Hero.frameWidth, Hero.frameWidth, Hero.frameHeight, Hero.image:getWidth(), Hero.image:getHeight()),
		love.graphics.newQuad(0, Hero.frameWidth*2, Hero.frameWidth, Hero.frameHeight, Hero.image:getWidth(), Hero.image:getHeight()), --Jumping Right
        love.graphics.newQuad(Hero.frameWidth, Hero.frameWidth*2, Hero.frameWidth, Hero.frameHeight, Hero.image:getWidth(), Hero.image:getHeight()),
        love.graphics.newQuad(Hero.frameWidth * 2, Hero.frameWidth*2, Hero.frameWidth, Hero.frameHeight, Hero.image:getWidth(), Hero.image:getHeight()),
		love.graphics.newQuad(Hero.frameWidth * 3, Hero.frameWidth*2, Hero.frameWidth, Hero.frameHeight, Hero.image:getWidth(), Hero.image:getHeight()),
		love.graphics.newQuad(Hero.frameWidth * 4, Hero.frameWidth*2, Hero.frameWidth, Hero.frameHeight, Hero.image:getWidth(), Hero.image:getHeight()),
		love.graphics.newQuad(0, Hero.frameWidth*3, Hero.frameWidth, Hero.frameHeight, Hero.image:getWidth(), Hero.image:getHeight()), --Idling left
        love.graphics.newQuad(Hero.frameWidth, Hero.frameWidth*3, Hero.frameWidth, Hero.frameHeight, Hero.image:getWidth(), Hero.image:getHeight()),
        love.graphics.newQuad(Hero.frameWidth * 2, Hero.frameWidth*3, Hero.frameWidth, Hero.frameHeight, Hero.image:getWidth(), Hero.image:getHeight()),
		love.graphics.newQuad(Hero.frameWidth * 3, Hero.frameWidth*3, Hero.frameWidth, Hero.frameHeight, Hero.image:getWidth(), Hero.image:getHeight()),
		love.graphics.newQuad(Hero.frameWidth * 4, Hero.frameWidth*3, Hero.frameWidth, Hero.frameHeight, Hero.image:getWidth(), Hero.image:getHeight()),
		love.graphics.newQuad(0, Hero.frameWidth*4, Hero.frameWidth, Hero.frameHeight, Hero.image:getWidth(), Hero.image:getHeight()), --Walking Left
        love.graphics.newQuad(Hero.frameWidth, Hero.frameWidth*4, Hero.frameWidth, Hero.frameHeight, Hero.image:getWidth(), Hero.image:getHeight()),
        love.graphics.newQuad(Hero.frameWidth * 2, Hero.frameWidth*4, Hero.frameWidth, Hero.frameHeight, Hero.image:getWidth(), Hero.image:getHeight()),
		love.graphics.newQuad(Hero.frameWidth * 3, Hero.frameWidth*4, Hero.frameWidth, Hero.frameHeight, Hero.image:getWidth(), Hero.image:getHeight()),
		love.graphics.newQuad(Hero.frameWidth * 4, Hero.frameWidth*4, Hero.frameWidth, Hero.frameHeight, Hero.image:getWidth(), Hero.image:getHeight()),
		love.graphics.newQuad(0, Hero.frameWidth*5, Hero.frameWidth, Hero.frameHeight, Hero.image:getWidth(), Hero.image:getHeight()), --Jumping Left
        love.graphics.newQuad(Hero.frameWidth, Hero.frameWidth*5, Hero.frameWidth, Hero.frameHeight, Hero.image:getWidth(), Hero.image:getHeight()),
        love.graphics.newQuad(Hero.frameWidth * 2, Hero.frameWidth*5, Hero.frameWidth, Hero.frameHeight, Hero.image:getWidth(), Hero.image:getHeight()),
		love.graphics.newQuad(Hero.frameWidth * 3, Hero.frameWidth*5, Hero.frameWidth, Hero.frameHeight, Hero.image:getWidth(), Hero.image:getHeight()),
		love.graphics.newQuad(Hero.frameWidth * 4, Hero.frameWidth*5, Hero.frameWidth, Hero.frameHeight, Hero.image:getWidth(), Hero.image:getHeight()),
		love.graphics.newQuad(0, Hero.frameWidth*6, Hero.frameWidth, Hero.frameHeight, Hero.image:getWidth(), Hero.image:getHeight()), --Attacking Right
        love.graphics.newQuad(Hero.frameWidth, Hero.frameWidth*6, Hero.frameWidth, Hero.frameHeight, Hero.image:getWidth(), Hero.image:getHeight()),
        love.graphics.newQuad(Hero.frameWidth * 2, Hero.frameWidth*6, Hero.frameWidth, Hero.frameHeight, Hero.image:getWidth(), Hero.image:getHeight()),
		love.graphics.newQuad(Hero.frameWidth * 3, Hero.frameWidth*6, Hero.frameWidth, Hero.frameHeight, Hero.image:getWidth(), Hero.image:getHeight()),
		love.graphics.newQuad(Hero.frameWidth * 4, Hero.frameWidth*6, Hero.frameWidth, Hero.frameHeight, Hero.image:getWidth(), Hero.image:getHeight()), 
		love.graphics.newQuad(0, Hero.frameWidth*7, Hero.frameWidth, Hero.frameHeight, Hero.image:getWidth(), Hero.image:getHeight()), --Attacking Left
        love.graphics.newQuad(Hero.frameWidth, Hero.frameWidth*7, Hero.frameWidth, Hero.frameHeight, Hero.image:getWidth(), Hero.image:getHeight()),
        love.graphics.newQuad(Hero.frameWidth * 2, Hero.frameWidth*7, Hero.frameWidth, Hero.frameHeight, Hero.image:getWidth(), Hero.image:getHeight()),
		love.graphics.newQuad(Hero.frameWidth * 3, Hero.frameWidth*7, Hero.frameWidth, Hero.frameHeight, Hero.image:getWidth(), Hero.image:getHeight()),
		love.graphics.newQuad(Hero.frameWidth * 4, Hero.frameWidth*7, Hero.frameWidth, Hero.frameHeight, Hero.image:getWidth(), Hero.image:getHeight())
	}
end

	--General Actions--
function GetMousePositions()
	MouseX = love.mouse.getX();
	MouseY = love.mouse.getY();
end

function GetHeroWidth()
	local Width;
		Width = HeroSS:getWidth()/5;
	return Width;
end
	--Hero Actions--
function GetEnergyLevel(dt)
	Hero.energyLevel = Hero.energyLevel + dt;
end

function ChangeHeroAnimation(dt)
Hero.elapsed = Hero.elapsed + dt
    if Hero.elapsed >= Hero.frameSpeed then
        Hero.elapsed = Hero.elapsed - Hero.frameSpeed
        if Hero.currentFrame == HeroFrameMax then
             Hero.currentFrame = HeroFrameMin
        else
            Hero.currentFrame = Hero.currentFrame + 1;
        end
    end
end

function SetHeroToIdleRight()
		Hero.currentFrame = 1;
		Hero.frameSpeed = .15;
		HeroFrameMax = 5;
		HeroFrameMin = 1;
end

function SetHeroToIdleLeft()
		Hero.currentFrame = 16;
		Hero.frameSpeed = .15;
		HeroFrameMax = 20;
		HeroFrameMin = 16;
end

function HeroActions(dt) --NOT USED ON MOBILE 
	if love.keyboard.isDown('d') and Hero.xPosition < (love.graphics.getWidth()-HeroSS:getWidth()/5) then
			Hero.frameSpeed = .1;
			HeroFrameMax = 10;
			HeroFrameMin = 6;
			Hero.xPosition = Hero.xPosition + (Hero.xVelocity * dt)
	elseif love.keyboard.isDown('a') then
			Hero.frameSpeed = .1;
			HeroFrameMax = 10;
			HeroFrameMin = 6;
			Hero.xPosition = Hero.xPosition - (Hero.xVelocity * dt)
	elseif love.keyboard.isDown("s") then
			if Hero.yVelocity == 0 then
				Hero.yVelocity = Hero.yHeight;
			end
	elseif Hero.frameSpeed ~= .15 then
		Hero.currentFrame = 1;
		Hero.frameSpeed = .15;
		HeroFrameMax = 5;
		HeroFrameMin = 1;
	end
end

function HeroJumpPhysics(dt)
	if Hero.yVelocity ~= 0 then --Decelerates the hero
		Hero.yPosition = Hero.yPosition + Hero.yVelocity * dt;
		Hero.yVelocity = Hero.yVelocity - Hero.gravity * dt;
	end
	if Hero.yPosition > GroundHeight then
		Hero.yVelocity = 0;
		Hero.yPosition = GroundHeight;
	end
end

function HeroActionsMouse(dt)
	if love.mouse.isDown("l") then
		GetStoppedEnemies();
		GetMousePositions();
			--Attacking Right
			if MouseX > love.graphics.getWidth() - Attack:getWidth() and MouseY > love.graphics.getHeight() - Attack:getHeight() and ATKcooldown == 0 and Hero.yVelocity ==0 and FacingLeft == false then	
				IsAttacking = true;				
				ATKcooldown = 2.5;
				Hero.currentFrame = 31;
				Hero.frameSpeed = .1;
				HeroFrameMax = 35;
				HeroFrameMin = 31;				
				TEsound.play("PhaseBladeSwing.wav");
				TEsound.play(AttackSounds);
			--Attacking Left
			elseif MouseX > love.graphics.getWidth() - Attack:getWidth() and MouseY > love.graphics.getHeight() - Attack:getHeight() and ATKcooldown == 0 and Hero.yVelocity ==0 and FacingLeft == true then
				IsAttacking = true;
				ATKcooldown = 2.5;
				Hero.currentFrame = 36;
				Hero.frameSpeed = .1;
				HeroFrameMax = 40;
				HeroFrameMin = 36;
				TEsound.play(AttackSounds);			
			end
			--Moving Hero to the left
			if MouseX < LeftMovement:getWidth() and MouseY >Background:getHeight() - LeftMovement:getHeight() and Hero.xPosition > 0 then
				EnemyStopped = false;
				if (Hero.yVelocity == 0) then
					if (Hero.currentFrame < 21) then
						Hero.currentFrame = 21;
					end
					Hero.frameSpeed = .1;
					HeroFrameMax = 25;
					HeroFrameMin = 21;
				end
			Hero.xPosition = Hero.xPosition - (Hero.xVelocity * dt);
			--Moving Hero to the right
			elseif MouseX < LeftMovement:getWidth()*3.5 and MouseX > LeftMovement:getWidth() * 2.5 and MouseY >Background:getHeight() - LeftMovement:getHeight() and Hero.xPosition < (love.graphics.getWidth()-HeroSS:getWidth()/5) and EnemyStopped == false then
				if (Hero.yVelocity == 0) then
				if (Hero.currentFrame < 6 or Hero.currentFrame > 10) then
					Hero.currentFrame = 6;
				end
					Hero.frameSpeed = .1;
					HeroFrameMax = 10;
					HeroFrameMin = 6;
				end
					Hero.xPosition = Hero.xPosition + (Hero.xVelocity * dt);
			--Makes hero Jump
			elseif MouseX > love.graphics.getWidth() - Jump:getWidth() * 3.5 and MouseX < love.graphics.getWidth() - Jump:getWidth() * 2.5 and Hero.yVelocity == 0 then
				if (FacingLeft == false) then --Jumping Right
					Hero.currentFrame = 11;
					Hero.frameSpeed = .125;
					HeroFrameMax = 12;
					HeroFrameMin = 11;
					JumpTimer = JumpTimer + dt;
						if JumpTimer > .25 then
							HeroFrameMax = 13;
							HeroFrameMin = 13;
							Hero.yVelocity = Hero.yHeight;
							TEsound.play(JumpSounds);
						end
			elseif (FacingLeft == true) then --Jumping Left
					Hero.currentFrame = 26;
					Hero.frameSpeed = .125;
					HeroFrameMax = 27;
					HeroFrameMin = 26;
					JumpTimer = JumpTimer + dt;
						if JumpTimer > .25 then
							HeroFrameMax = 28;
							HeroFrameMin = 28;
							Hero.yVelocity = Hero.yHeight;
							TEsound.play(JumpSounds);
						end
			end
		end
	end
end

--Hero Idle State Functions
function love.mousereleased(x, y, button)--When mouse is released, it ensures the hero goes back to the idle animation
	if button == "l" then
		if x < LeftMovement:getWidth() and y > Background:getHeight() - LeftMovement:getHeight()then --for walking left
			SetHeroToIdleLeft();
			JumpTimer = 0;
			FacingLeft = true;
		elseif x < LeftMovement:getWidth()*3.5 and x > LeftMovement:getWidth() * 2.5 and y >Background:getHeight() - LeftMovement:getHeight() then --for walking right
			SetHeroToIdleRight();
			JumpTimer = 0;
			FacingLeft = false;
		elseif x > love.graphics.getWidth() - Attack:getWidth() and y > love.graphics.getHeight() - Attack:getHeight() and IsAttacking == false then
			if (FacingLeft == true) then
				SetHeroToIdleLeft();
			elseif (FacingLeft == false) then
				SetHeroToIdleRight();
			end
		end
	end
end

function HeroCooldown(dt)
	ATKcooldown = math.max(ATKcooldown - dt,0);
	if ATKcooldown < 2 and IsAttacking == true and FacingLeft == false then
		SetHeroToIdleRight();
		IsAttacking = false;
	elseif ATKcooldown < 2 and IsAttacking == true and FacingLeft == true then
		SetHeroToIdleLeft();
		IsAttacking = false;
	end
end

function IdlePostJump()
	if (MouseX > love.graphics.getWidth() - Jump:getWidth() * 3.5 and MouseX < love.graphics.getWidth() - Jump:getWidth() * 2.5 and Hero.yVelocity == 0 and (HeroFrameMax == 13 or HeroFrameMax == 28)) then
		JumpTimer = 0;
		if (FacingLeft == false) then
			SetHeroToIdleRight();
		else
			SetHeroToIdleLeft();
		end
	end
end

function GetATKrangeRight()
	AttackRangeRight = Hero.xPosition + Hero.frameWidth * .5;
	return AttackRangeRight;
end

function GetATKrangeLeft()
	AttackRangeLeft = Hero.xPosition;
	return AttackRangeLeft;
end

function HeroAttackCollision(dt)
	if (IsAttacking == true and FacingLeft == false) then
		for k,v in ipairs(Enemies) do
			--print(v);
			for k2, v2 in ipairs(v) do
				if GetATKrangeRight() > v2.xPosition and GetATKrangeRight() < v2.xPosition + v2.frameWidth then		
						v2.currentFrame = 2;
						v2.FrameMax = 10;--These frames will be the enemy exploding
						v2.FrameMin = 6;
						DeathDelay = DeathDelay + dt;	--Starts the death delay so the heroes attack animation runs fully before enemy is deleted			
						DeathIndex = k;						
				end
			end		
		end
	end
	if (IsAttacking == true and FacingLeft == true) then
		for k,v in ipairs(Enemies) do
			--print(v);
			for k2, v2 in ipairs(v) do
				if GetATKrangeLeft() > v2.xPosition and GetATKrangeLeft() < v2.xPosition + v2.frameWidth then	
						DeathDelay = DeathDelay + dt;	--Starts the death delay so the heroes attack animation runs fully before enemy is deleted			
						DeathIndex = k;						
				end
			end		
		end
	end
end

function RemoveEnemy(dt)
for k,v in ipairs(Enemies) do
			--print(v);
			for k2, v2 in ipairs(v) do
				if (v2.currentFrame == 6 and v2.DeathSoundPlayed == false) then
					TEsound.play("PhaseBladeHit2.wav");
					v2.DeathSoundPlayed = true;
				end
				if (v2.currentFrame == 10) then		--Removes enemy at the end of their death animation			
					table.remove(Enemies, k);			
					EnemyStopped = false;
					Score = Score + 1;
					DeathDelay = 0;					
				end
			end		
		end
end

function RemoveEnemyOld(dt)
	if (DeathDelay > .24) then		
		DeathDelay = DeathDelay + dt;
		if (DeathDelay > 1.5) then
			TEsound.play("PhaseBladeHit4.wav");
			table.remove(Enemies, DeathIndex);			
			EnemyStopped = false;
			Score = Score + 1;
			DeathDelay = 0;
		end
	end
end

	--Enemies--
function SpawnEnemies(dt)
	EnemyTimer = EnemyTimer + dt;
		if EnemyTimer > ConstantRandom then
			Enemies[#Enemies+1]={
				EnemySpriteSheet:new(EnemySS, EnemySS:getWidth()/5, EnemySS:getWidth()/5);
			}
			ConstantRandom = math.random(2,5);
			EnemyTimer = 0;
		end	
end

function UpdateEnemies(dt)
	for k,v in ipairs(Enemies) do
		--print(v);
		for k2, v2 in ipairs(v) do
			v2:Update(dt);
		end		
	end
end

function DrawEnemies()
	for k,v in ipairs(Enemies) do
		--print(v);
		for k2, v2 in ipairs(v) do
			v2:Draw();
		end		
	end
end

function GetStoppedEnemies()	
	for k,v in ipairs(Enemies) do
		--print(v);
		for k2, v2 in ipairs(v) do
			if (v2.xVelocity == 0) then
				EnemyStopped = true;
			end
		end		
	end
	return EnemyStopped;
end
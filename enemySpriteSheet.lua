local EnemySheet = {}
local EnemySheet_mt = {}
EnemySheet_mt.__index = EnemySheet

function EnemySheet:new(image, frameWidth, frameHeight)
    local enemysheet = {}
		enemysheet.image = image;
		enemysheet.frameWidth = frameWidth;
		enemysheet.frameHeight = frameHeight;
		enemysheet.frameSpeed = .15;
		enemysheet.numberOfRows = enemysheet.image:getHeight() / enemysheet.frameHeight;
		enemysheet.numberOfColumns = enemysheet.image:getWidth() / enemysheet.frameWidth;
		enemysheet.xPosition = love.graphics.getWidth() - EnemySS:getWidth()/5;
		enemysheet.yPosition = Background:getHeight() - EnemySS:getHeight()/2 - GroundLevel:getHeight();
		enemysheet.xVelocity = -75;
		enemysheet.yVelocity = 0;
		enemysheet.yHeight = -550;
		enemysheet.gravity = -500;	
		enemysheet.elapsed = 0;
		enemysheet.energyLevel = 0;
		enemysheet.currentFrame = 1;
		enemysheet.FrameMax = 5;
		enemysheet.FrameMin = 1;
		enemysheet.DeathSoundPlayed = false;
		enemysheet.EnemyFrames = 
		{
		love.graphics.newQuad(0, 0, enemysheet.frameWidth, enemysheet.frameWidth, enemysheet.image:getWidth(), enemysheet.image:getHeight()), --Moving
        love.graphics.newQuad(enemysheet.frameWidth, 0, enemysheet.frameWidth, enemysheet.frameHeight, enemysheet.image:getWidth(), enemysheet.image:getHeight()),
        love.graphics.newQuad(enemysheet.frameWidth * 2, 0, enemysheet.frameWidth, enemysheet.frameHeight, enemysheet.image:getWidth(), enemysheet.image:getHeight()),
		love.graphics.newQuad(enemysheet.frameWidth * 3, 0, enemysheet.frameWidth, enemysheet.frameHeight, enemysheet.image:getWidth(), enemysheet.image:getHeight()),
		love.graphics.newQuad(enemysheet.frameWidth * 4, 0, enemysheet.frameWidth, enemysheet.frameHeight, enemysheet.image:getWidth(), enemysheet.image:getHeight()),
		love.graphics.newQuad(enemysheet.frameWidth * 0, enemysheet.frameWidth, enemysheet.frameWidth, enemysheet.frameHeight, enemysheet.image:getWidth(), enemysheet.image:getHeight()),
		love.graphics.newQuad(enemysheet.frameWidth * 1, enemysheet.frameWidth, enemysheet.frameWidth, enemysheet.frameHeight, enemysheet.image:getWidth(), enemysheet.image:getHeight()),
		love.graphics.newQuad(enemysheet.frameWidth * 2, enemysheet.frameWidth, enemysheet.frameWidth, enemysheet.frameHeight, enemysheet.image:getWidth(), enemysheet.image:getHeight()),
		love.graphics.newQuad(enemysheet.frameWidth * 3, enemysheet.frameWidth, enemysheet.frameWidth, enemysheet.frameHeight, enemysheet.image:getWidth(), enemysheet.image:getHeight()),
		love.graphics.newQuad(enemysheet.frameWidth * 4, enemysheet.frameWidth, enemysheet.frameWidth, enemysheet.frameHeight, enemysheet.image:getWidth(), enemysheet.image:getHeight())
		}		
    return setmetatable(enemysheet, EnemySheet_mt)
end

function EnemySheet:Draw()
	love.graphics.draw(self.image, self.EnemyFrames[self.currentFrame], self.xPosition, self.yPosition);
end

function EnemySheet:Update(dt)
	--Updates the x Position using Velocity
	self.xPosition = self.xPosition + (self.xVelocity * dt);
	--Updates the frames for animation
	self.elapsed = self.elapsed + dt;
    if self.elapsed >= self.frameSpeed then
        self.elapsed = self.elapsed - self.frameSpeed
        if self.currentFrame == self.FrameMax then
             self.currentFrame = self.FrameMin
        else
            self.currentFrame = self.currentFrame + 1;
        end
    end
	--Stops enemy if hero is in range, or moves towards hero if hero moves
	if (self.currentFrame > 6 and self.currentFrame < 11) then
		self.xVelocity = 0;
	elseif (self.xPosition < (Hero.xPosition+Hero.frameWidth*.333)) then
		self.xVelocity = 0;
	elseif (self.xPosition > (Hero.xPosition+Hero.frameWidth*.333)) then
		self.xVelocity = -75;
	end
end

function EnemySheet:remove()
  self = nil;
end

return EnemySheet
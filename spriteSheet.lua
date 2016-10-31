local SpriteSheet = {}
local SpriteSheet_mt = {}
SpriteSheet_mt.__index = SpriteSheet

function SpriteSheet:new(image, frameWidth, frameHeight)
    local spritesheet = {}
		spritesheet.image = image;
		spritesheet.frameWidth = frameWidth;
		spritesheet.frameHeight = frameHeight;
		spritesheet.frameSpeed = .15;
		spritesheet.numberOfRows = spritesheet.image:getHeight() / spritesheet.frameHeight;
		spritesheet.numberOfColumns = spritesheet.image:getWidth() / spritesheet.frameWidth;
		spritesheet.xPosition = 0;
		spritesheet.yPosition = Background:getHeight() - HeroSS:getWidth()/5 - GroundLevel:getHeight();
		spritesheet.xVelocity = 200;
		spritesheet.yVelocity = 0;
		spritesheet.yHeight = -550;
		spritesheet.gravity = -500;	
		spritesheet.elapsed = 0;
		spritesheet.energyLevel = 0;
		spritesheet.currentFrame = 1;
    return setmetatable(spritesheet, SpriteSheet_mt)
end

return SpriteSheet
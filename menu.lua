Menu ={}
function Menu.drawBG()
	local width = love.graphics.getWidth();
	local height = love.graphics.getHeight();
	love.graphics.setColor(0,0,0);
	love.graphics.rectangle("fill", 0, 0, width, height);
end

function Menu.drawPlay()
	local width = love.graphics.getWidth();
	local buttonWidth = width/3;
	local height = love.graphics.getHeight();
	local buttonHeight = height/10;
	love.graphics.setColor(255,0,0);
	love.graphics.rectangle("fill", (width/2)-(buttonWidth/2), height/4, buttonWidth, buttonHeight);
	love.graphics.setColor(255,255,255);
	love.graphics.print("PLAY",(width/2)-(buttonWidth/2), height/4);
end

function Menu.update(dt)
	if love.mouse.isDown("l") then
		CurrentState = "game";
	end
end
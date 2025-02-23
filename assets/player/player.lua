player = {}
local isDown = love.keyboard.isDown

-- Player attributes
function player.load()
    player.x = 0
    player.y = 0
    player.width = 10
    player.height = 10
    player.xvel = 0
    player.yvel = 0
    player.friction = 1
    player.speed = 200
    player.jumpspeed = -200
    player.gravity = 500
    player.grounded = false
    player.lastOnGroundTime = 0
    player.lastOnWallTime = 0
    player.lastOnWallRightTime = 0
    player.lastOnWallLeftTime = 0
    player.isJumping = false
    player.isWallJumping = false
    player.isSliding = false
    player.jumpBuffer = 0.2 -- Time window to jump after leaving the ground
    player.lastJumpTime = 0.3
    player.coyoteTime = 0.1 -- Time to allow jump after leaving the ground
    player.wallJumpTime = 0.2 -- Time to allow wall jump after touching wall
    player.gravityScale = 1
    player.maxFallSpeed = 500
    player.fastFallGravityMult = 2
    player.jumpCutGravityMult = 1.5
    player.fallGravityMult = 1.5
    player.runMaxSpeed = 200
    player.runAccelAmount = 400
    player.runDeccelAmount = 200
    player.accelInAir = 0.5
    player.deccelInAir = 0.5
    player.jumpHangTimeThreshold = 50
    player.jumpHangAccelerationMult = 1.2
    player.jumpHangMaxSpeedMult = 1.2
    player.slideSpeed = 100
    player.slideAccel = 300
    player.SpriteSheet = love.graphics.newImage(assets/player/sprite/player-sheet.png)
    player.grid = anim8.newGrid(16,16,player.spriteSheet:getWidth(),player.spriteSheet:getHeight())
	player.animations = {}
	player.animations.down = anim8.newAnimation(player.grid('1-4',1),0.2,0)
end

-- Draw the player
function player.draw()
    love.graphics.setColor(255, 255, 255)
    love.graphics.rectangle("fill", player.x, player.y, player.width, player.height)
end

-- Handle physics and gravity
function player.physics(dt)
    -- Apply gravity
    if not player.grounded then
        player.yvel = player.yvel + player.gravity * player.gravityScale * dt
    else
        player.yvel = 0 -- Reset vertical velocity if grounded
    end

    -- Update position
    player.x = player.x + player.xvel * dt
    player.y = player.y + player.yvel * dt

    -- Check for ground collision (simple floor check)
    if player.y >= love.graphics.getHeight() - player.height then
        player.y = love.graphics.getHeight() - player.height -- Reset position to ground level
        player.grounded = true -- Set grounded to true
    else
        player.grounded = false -- Not grounded if above the ground
    end

    -- Coyote time handling
    if player.grounded then
        player.lastOnGroundTime = player.coyoteTime
    else
        player.lastOnGroundTime = player.lastOnGroundTime - dt
    end

    -- Wall checks (simple left/right wall check)
    if player.x <= 0 or player.x + player.width >= love.graphics.getWidth() then
        player.lastOnWallTime = player.lastOnWallTime + dt
    else
        player.lastOnWallTime = 0
    end
end

-- Handle movement
function player.move(dt)
    local right = isDown("d")
    local left = isDown("a")
    local jump = isDown("space")

    -- Horizontal movement
    if left then
        player.xvel = -player.speed
    elseif right then
        player.xvel = player.speed
    else
        player.xvel = 0 -- Stop horizontal movement if no key is pressed
    end

    -- Jumping
    if jump then
        if player.grounded then
            player.yvel = player.jumpspeed
            player.grounded = false -- Set grounded to false after jumping
            player.lastOnGroundTime = 0
        end
    else
        -- Stop upward movement when space is released
        if player.yvel < 0 then
            player.yvel = 0
        end
    end

    -- Wall Jumping
    if jump and player.lastOnWallTime > 0 and not player.grounded then
        player.yvel = player.jumpspeed
        player.xvel = (right and player.speed or -player.speed) -- Jump away from the wall
        player.lastOnWallTime = 0
    end

    -- Sliding
    if player.lastOnWallTime > 0 and not player.grounded then
        player.isSliding = true
        player.yvel = player.slideSpeed
    else
        player.isSliding = false
    end

    -- Apply friction
    player.xvel = player.xvel * (1 - math.min(dt * player.friction, 1))
end

-- Update function to manage player state
function player.UPDATE(dt)
    player.physics(dt)
    player.move(dt)
end

-- Draw function to render the player
function player.DRAW()
    player.draw()
end

-- Load player attributes
function player.LOAD()
    player.load()
end
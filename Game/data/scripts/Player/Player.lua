
PlayerMeta = {}


function PlayerMeta:initializeGameObjectWood( )
	logMessage("PlayerMeta:init() start ")
	local cinfo = RigidBodyCInfo()
	local materialTable = Config.materials.sphere.wood
	cinfo.shape = PhysicsFactory:createSphere(materialTable.radius)
	cinfo.motionType = MotionType.Dynamic
	cinfo.mass = materialTable.mass
	cinfo.restitution = materialTable.restitution
	cinfo.friction = materialTable.friction
	cinfo.maxLinearVelocity = Config.player.maxLinearVelocity
	cinfo.maxAngularVelocity = Config.player.maxAngularVelocity
	--cinfo.linearDamping = materialTable.linearDamping
	cinfo.angularDamping = materialTable.angularDamping
	cinfo.position = Config.player.spawnPosition
	CreatePhysicsComponent( self , cinfo )
	CreateRenderComponent(self, "data/models/Sphere/SphereWood.thmodel")
	
	self.lastTransformator = Config.player.lastTransformator
	logMessage("PlayerMeta:init() end")

	--self.ac = self.go:createAnimationComponent()
	--self.ac:setSkinFile("data/animations/barbarian/barbarian.hkt")
	--self.ac:setSkeletonFile("data/animations/barbarian/barbarian.hkt")

	--self.ac:addAnimationFile("FOO","data/animations/barbarian/barbarian_walk.hkt")
end


function PlayerMeta:initializeGameObjectStone( )
	logMessage("PlayerMeta:initStone() start ")
	local cinfo = RigidBodyCInfo()
	local materialTable = Config.materials.sphere.stone
	cinfo.shape = PhysicsFactory:createSphere(materialTable.radius)
	cinfo.motionType = MotionType.Dynamic
	cinfo.mass = materialTable.mass 
	cinfo.restitution = materialTable.restitution
	cinfo.friction = materialTable.friction
	cinfo.maxLinearVelocity = Config.player.maxLinearVelocity 
	cinfo.maxAngularVelocity = Config.player.maxAngularVelocity
	--cinfo.linearDamping = materialTable.linearDamping
	cinfo.angularDamping = materialTable.angularDamping 
	cinfo.position = Config.player.spawnPosition
	CreatePhysicsComponent( self , cinfo )
	CreateRenderComponent(self, "data/models/Sphere/SphereMarble.thmodel")
	self.lastTransformator = Config.player.lastTransformator
	logMessage("PlayerMeta:initStone() end")
end

function PlayerMeta:initializeGameObjectPaper( )
	logMessage("PlayerMeta:initPaper() start ")
	local cinfo = RigidBodyCInfo()
	local materialTable = Config.materials.sphere.paper
	cinfo.shape = PhysicsFactory:createSphere(materialTable.radius)
	cinfo.motionType = MotionType.Dynamic
	cinfo.mass = materialTable.mass 
	cinfo.restitution = materialTable.restitution
	cinfo.friction = materialTable.friction
	cinfo.maxLinearVelocity = Config.player.maxLinearVelocity 
	cinfo.maxAngularVelocity = Config.player.maxAngularVelocity
	--cinfo.linearDamping = materialTable.linearDamping
	cinfo.angularDamping = materialTable.angularDamping 
	cinfo.position = Config.player.spawnPosition
	CreatePhysicsComponent( self , cinfo )
	CreateRenderComponent(self, "data/models/Sphere/SpherePaper.thmodel")
	self.lastTransformator = Config.player.lastTransformator
	logMessage("PlayerMeta:initPaper() end")
end

function PlayerMeta.update( guid, elapsedTime )

	local player = GetGObyGUID(guid)
	local pos = GameLogic.isoCam.trackingObject.go:getWorldPosition()
	if(GameLogic.debugDrawings == true) then
		DebugRenderer:printText(Vec2(-0.9, 0.65), "Velocity:" .. player.go.rb:getLinearVelocity():length())
		DebugRenderer:printText(Vec2(-0.9, 0.55), "X:" .. pos.x)
		DebugRenderer:printText(Vec2(-0.9, 0.50), "Y:" .. pos.y)
		DebugRenderer:printText(Vec2(-0.9, 0.45), "Z:" .. pos.z)
	end
	local viewDir = GameLogic.isoCam.go.cc:getViewDirection()
	viewDir.z = 0
	viewDir = viewDir:normalized()
	local rightDir = viewDir:cross(Vec3(0.0, 0.0, 1.0))
	local mouseDelta = InputHandler:getMouseDelta()

	local movementDirection = Vec3(0,0,0)
	-- restart game
	if(InputHandler:isPressed(Config.keys.keyboard.restart)) then
		GameLogic.restart()
	end
	local buttonsTriggered = InputHandler:gamepad(0):buttonsTriggered()
	if InputHandler:gamepad(0):isConnected() then
		if (bit32.btest(buttonsTriggered, Config.keys.gamepad.restart) ) then
			GameLogic.restart()
		end
		endmovementDirection = movementDirection:add(viewDir:mulScalar(InputHandler:gamepad(0):leftStick().x))
		movementDirection = movementDirection:add(rightDir:mulScalar(-InputHandler:gamepad(0):leftStick().y))
	end


	-- set position to last transformator
	if(InputHandler:isPressed(Config.keys.keyboard.lastTransformator)) then
		GameLogic.lastTransformator()
	end
	local buttonsTriggered = InputHandler:gamepad(0):buttonsTriggered()
	if InputHandler:gamepad(0):isConnected() then
		if (bit32.btest(buttonsTriggered, Config.keys.gamepad.lastTransformator) ) then
			GameLogic.lastTransformator()
		end
		movementDirection = movementDirection:add(viewDir:mulScalar(InputHandler:gamepad(0):leftStick().x))
		movementDirection = movementDirection:add(rightDir:mulScalar(-InputHandler:gamepad(0):leftStick().y))
	end

	-- movement

	if (InputHandler:isPressed(Config.keys.keyboard.left)) then
		--player.pc.rb:applyLinearImpulse(rightDir:mulScalar(-moveSpeed))
		player.go.angularVelocitySwapped = false
		movementDirection = movementDirection:add(-viewDir)
	end
	if (InputHandler:isPressed(Config.keys.keyboard.right)) then
		--player.pc.rb:applyLinearImpulse(rightDir:mulScalar(moveSpeed))
		player.go.angularVelocitySwapped = false
		movementDirection = movementDirection:add(viewDir)
	end

	if (InputHandler:isPressed(Config.keys.keyboard.forward)) then
		--player.pc.rb:applyLinearImpulse(rightDir:mulScalar(moveSpeed))
		player.go.angularVelocitySwapped = false
		movementDirection = movementDirection:add(-rightDir)
	end
	if (InputHandler:isPressed(Config.keys.keyboard.backward)) then
		--player.pc.rb:applyLinearImpulse(rightDir:mulScalar(moveSpeed))
		player.go.angularVelocitySwapped = false
		movementDirection = movementDirection:add(rightDir)
	end

	-- development-jump-to-transformator-section
	if (InputHandler:isPressed(Key.Numpad1) or InputHandler:isPressed(Key.J)) then
		GameLogic.isoCam.trackingObject.go:setPosition(Config.transformators.transformator1.position)
	end
	if (InputHandler:isPressed(Key.Numpad2)or InputHandler:isPressed(Key.K)) then
		GameLogic.isoCam.trackingObject.go:setPosition(Config.transformators.transformator2.position)
	end
	if (InputHandler:isPressed(Key.Numpad3) or InputHandler:isPressed(Key.L)) then
		GameLogic.isoCam.trackingObject.go:setPosition(Config.transformators.transformator3.position)
	end
	if (InputHandler:isPressed(Key.Numpad4)or InputHandler:isPressed(Key.U)) then
		GameLogic.isoCam.trackingObject.go:setPosition(Config.transformators.transformator4.position)
	end

	local linearVelocity = Vec3(movementDirection.y,-movementDirection.x,movementDirection.z)
	player.go.rb:applyLinearImpulse(linearVelocity:mulScalar(Config.player.linearVelocityScalar*elapsedTime))
	player.go.rb:applyTorque(elapsedTime, movementDirection:mulScalar(Config.player.torqueMulScalar))
end



function PlayerMeta.init( guid )
	-- body
	logMessage("PlayerMeta.init!")
end

function PlayerMeta.destroy( ... )
	-- body
	logMessage("PlayerMeta.destroy!")
end

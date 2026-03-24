extends Object

const id = "MSLaFaver-MountainDew"

func MainShellRoutine(chain: ModLoaderHookChain):
	if ModLoader.get_node(id).god_help_us_all:
		var shellSpawner = chain.reference_object
		var socket = CameraSocket.new()
		socket.socketName = "shell compartment"
		socket.pos = Vector3(-6.165,6.146,0.801)
		socket.rot = Vector3(-43,-150.5,11.7)
		socket.fov = 86
		shellSpawner.camera.socketArray[1] = socket
		
		shellSpawner.roundManager.roundArray[shellSpawner.roundManager.currentRound].amountLive = 1000
		shellSpawner.roundManager.roundArray[shellSpawner.roundManager.currentRound].amountBlank = 0
		shellSpawner.roundManager.health_player = 2
		shellSpawner.roundManager.health_opponent = 2
		for i in range(0,7):
			for j in range(1,12):
				for k in range(1,12):
					var newshell = shellSpawner.shellInstance.instantiate()
					shellSpawner.spawnParent.add_child(newshell)
					newshell.transform.origin = shellSpawner.shellLocationArray[i]
					newshell.transform.origin += Vector3((k - 6) * 1.6,j * 0.4,0)
					newshell.rotation_degrees.y = -90
		shellSpawner.roundManager.playerData.skippingShellDescription = false
		shellSpawner.roundManager.playerData.numberOfDialogueRead = 2
	chain.execute_next_async()

func SpawnShells(chain: ModLoaderHookChain, numberOfShells : int, numberOfLives : int, numberOfBlanks : int, shufflingArray : bool):
	if ModLoader.get_node(id).god_help_us_all:
		numberOfShells = 8
		numberOfLives = 8
		numberOfBlanks = 0
	chain.execute_next_async([numberOfShells, numberOfLives, numberOfBlanks, shufflingArray])

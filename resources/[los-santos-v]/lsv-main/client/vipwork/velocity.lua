local vehicle = nil
local vehicleBlip = nil
local detonationSound = nil


AddEventHandler('lsv:startVelocity', function()
	local location = Utils.GetRandom(Settings.velocity.locations)

	Streaming.RequestModel('voltic2')

	local vehicleHash = GetHashKey('voltic2')
	vehicle = CreateVehicle(vehicleHash, location.x, location.y, location.z, location.heading, false, true)
	SetVehicleModKit(vehicle, 0)
	SetVehicleMod(vehicle, 16, 4)

	SetModelAsNoLongerNeeded(vehicleHash)

	vehicleBlip = AddBlipForEntity(vehicle)
	SetBlipColour(vehicleBlip, Color.BlipYellow())
	SetBlipHighDetail(vehicleBlip, true)
	SetBlipRouteColour(vehicleBlip, Color.BlipYellow())
	SetBlipRoute(vehicleBlip, true)

	Player.StartVipWork('Velocity')

	PlaySoundFrontend(-1, 'CONFIRM_BEEP', 'HUD_MINI_GAME_SOUNDSET', true)
	Gui.DisplayNotification('You have started Velocity. Enter the Rocket Voltic and stay above minimum speed to avoid detonation.')

	detonationSound = GetSoundId()

	local isInVehicle = false
	local preparationStage = nil
	local detonationStage = nil

	local eventStartTime = GetGameTimer()
	local startTimeToDetonate = GetGameTimer()
	local startPreparationStageTime = GetGameTimer()

	Citizen.CreateThread(function()
		while true do
			Citizen.Wait(0)

			if Player.isEventInProgress then
				local totalTime = Settings.velocity.enterVehicleTime
				if preparationStage then totalTime = Settings.velocity.preparationTime
				elseif detonationStage then totalTime = Settings.velocity.detonationTime
				elseif isInVehicle and not preparationStage then totalTime = Settings.velocity.driveTime end

				local title = 'VIP WORK END'
				if preparationStage then title = 'BOMB ACTIVATION'
				elseif detonationStage then title = 'DETONATE IN' end

				local startTime = eventStartTime
				if detonationStage then startTime = startTimeToDetonate
				elseif preparationStage then startTime = startPreparationStageTime end

				Gui.DrawTimerBar(preparationStage and 0.16 or 0.13, title, math.max(0, math.floor((totalTime - GetGameTimer() + startTime) / 1000)))

				if isInVehicle then
					local vehicleSpeedMph = math.floor(GetEntitySpeed(vehicle) * 2.236936)
					Gui.DrawBar(0.13, 'SPEED', vehicleSpeedMph..' MPH', nil, 2)
				end

				Gui.DisplayObjectiveText(isInVehicle and 'Stay above '..Settings.velocity.minSpeed..' mph to avoid detonation.' or 'Enter the ~y~Rocket Voltic~w~.')
			else return end
		end
	end)

	while true do
		Citizen.Wait(0)

		if not DoesEntityExist(vehicle) or not IsVehicleDriveable(vehicle, false) then
			TriggerEvent('lsv:velocityFinished', false, 'A vehicle has been destroyed.')
			return
		end

		isInVehicle = IsPedInVehicle(PlayerPedId(), vehicle, false)
		if isInVehicle then
			if not NetworkGetEntityIsNetworked(vehicle) then NetworkRegisterEntityAsNetworked(vehicle) end

			if preparationStage == nil then
				preparationStage = true
				startPreparationStageTime = GetGameTimer()
			elseif preparationStage then
				if GetTimeDifference(GetGameTimer(), startPreparationStageTime) >= Settings.velocity.preparationTime then
					preparationStage = false
					eventStartTime = GetGameTimer()
				end
			elseif GetTimeDifference(GetGameTimer(), eventStartTime) < Settings.velocity.driveTime then
				local vehicleSpeedMph = math.floor(GetEntitySpeed(vehicle) * 2.236936) -- https://runtime.fivem.net/doc/reference.html#_0xD5037BA82E12416F

				if vehicleSpeedMph < Settings.velocity.minSpeed then
					if not detonationStage then
						detonationStage = true
						startTimeToDetonate = GetGameTimer()
						PlaySoundFrontend(detonationSound, '5s_To_Event_Start_Countdown', 'GTAO_FM_Events_Soundset', false)
					end

					if GetTimeDifference(GetGameTimer(), startTimeToDetonate) >= Settings.velocity.detonationTime then
						local vehicleNetId = NetworkGetNetworkIdFromEntity(vehicle)
						NetworkRequestControlOfNetworkId(vehicleNetId)
						while not NetworkHasControlOfNetworkId(vehicleNetId) do Citizen.Wait(0) end

						Citizen.Wait(1000)

						NetworkExplodeVehicle(vehicle, true, false, false)

						TriggerEvent('lsv:velocityFinished', false, 'The bomb has detonated.')
						return
					end
				elseif detonationStage then
					if not HasSoundFinished(detonationSound) then StopSound(detonationSound) end
					detonationStage = false
				end
			else
				TriggerServerEvent('lsv:velocityFinished')
				return
			end
		elseif GetTimeDifference(GetGameTimer(), eventStartTime) >= Settings.velocity.enterVehicleTime then
			TriggerEvent('lsv:velocityFinished', false, 'Time is over.')
			return
		end

		SetBlipAlpha(vehicleBlip, isInVehicle and 0 or 255)
	end
end)


RegisterNetEvent('lsv:velocityFinished')
AddEventHandler('lsv:velocityFinished', function(success, reason)
	Player.FinishVipWork('Velocity')

	vehicle = nil

	RemoveBlip(vehicleBlip)
	vehicleBlip = nil

	if not HasSoundFinished(detonationSound) then StopSound(detonationSound) end
	ReleaseSoundId(detonationSound)
	detonationSound = nil

	StartScreenEffect("SuccessMichael", 0, false)

	if success then PlaySoundFrontend(-1, 'Mission_Pass_Notify', 'DLC_HEISTS_GENERAL_FRONTEND_SOUNDS', true) end

	local status = success and 'COMPLETED' or 'FAILED'
	local message = success and '+'..Settings.velocity.reward..' RP' or reason or ''

	local scaleform = Scaleform:Request('MIDSIZED_MESSAGE')

	scaleform:Call('SHOW_SHARD_MIDSIZED_MESSAGE', 'VELOCITY '..status, message)
	scaleform:RenderFullscreenTimed(5000)

	scaleform:Delete()
end)
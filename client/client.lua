local Config = lib.require('config')

local function showMultijob()
    local PlayerData = RSGCore.Functions.GetPlayerData()
    local dutyStatus = PlayerData.job.onduty and 'On Duty' or 'Off Duty'
    local dutyIcon = PlayerData.job.onduty and 'fa-solid fa-toggle-on' or 'fa-solid fa-toggle-off'
    local colorIcon = PlayerData.job.onduty and '#5ff5b4' or 'red'
    local jobMenu = {
        id = 'job_menu',
        title = 'My Jobs',
        options = {
            {
                title = 'Toggle Duty',
                description = 'Current Status: ' .. dutyStatus,
                icon = dutyIcon,
                iconColor = colorIcon,
                onSelect = function()
                    TriggerServerEvent('RSGCore:ToggleDuty')
                    Wait(500)
                    showMultijob()
                end,
            },
        },
    }
    local myJobs = lib.callback.await('rsg-multijob:server:myJobs', false)
    if myJobs then
        for _, job in ipairs(myJobs) do
            local isDisabled = PlayerData.job.name == job.job
            jobMenu.options[#jobMenu.options + 1] = {
                title = job.jobLabel,
                description = ('Grade: %s [%s]\nSalary: $%s'):format(job.gradeLabel, tonumber(job.grade), job.salary),
                icon = Config.JobIcons[job.job] or 'fa-solid fa-briefcase',
                arrow = true,
                disabled = isDisabled,
                event = 'rsg-multijob:client:choiceMenu',
                args = {jobLabel = job.jobLabel, job = job.job, grade = job.grade},
            }
        end
        lib.registerContext(jobMenu)
        lib.showContext('job_menu')
    end
end

AddEventHandler('rsg-multijob:client:choiceMenu', function(args)
    local displayChoices = {
        id = 'choice_menu',
        title = 'Job Actions',
        menu = 'job_menu',
        options = {
            {
                title = 'Switch Job',
                description = ('Switch your job to: %s'):format(args.jobLabel),
                icon = 'fa-solid fa-circle-check',
                onSelect = function()
                    TriggerServerEvent('rsg-multijob:server:changeJob', args.job)
                    Wait(100)
                    showMultijob()
                end,
            },
            {
                title = 'Delete Job',
                description = ('Delete the selected job: %s'):format(args.jobLabel),
                icon = 'fa-solid fa-trash-can',
                onSelect = function()
                    TriggerServerEvent('rsg-multijob:server:deleteJob', args.job)
                    Wait(100)
                    showMultijob()
                end,
            },
        }
    }
    lib.registerContext(displayChoices)
    lib.showContext('choice_menu')
end)

RegisterNetEvent('RSGCore:Client:OnJobUpdate', function(JobInfo)
    TriggerServerEvent('rsg-multijob:server:newJob', JobInfo)
end)

RegisterNetEvent('rsg-multijob:client:openmenu', function()
	showMultijob()
end)

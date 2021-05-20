require('hs.ipc')

hs.ipc.cliSaveHistory(true)
hs.ipc.cliColors({
    initial = "\27[32m", -- Green
    input   = "\27[30m", -- Black
    output  = "\27[36m", -- Blue-grey
    error   = "\27[31m", -- Red
})

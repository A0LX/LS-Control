_G.LSDropper = {
    -- Controllers: Enter the UserID's of the players that can control the bots.
    Controllers = {
        "707293189",
    },
    
    -- alts: Put all alt user IDs here
    alts = {
        [1] = 2939174150,
        [2] = 3281293170,
        [3] = 3034352629,
        [4] = 2827160867,
        -- Add more here if needed, up to [38] etc.
    },
    
    -- Prefix: Enter the prefix before each command.
    Prefix = "/"
}

-- Loader: Loads the main script logic
loadstring(game:HttpGet("https://raw.githubusercontent.com/LS-AltControl/LS-Control/refs/heads/main/Loader.lua"))()

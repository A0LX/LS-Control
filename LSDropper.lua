_G.LSDropper = {
    -- Controllers: Enter the UserID's of the players that can control the bots.
    Controllers = {
        "228432957",
    },
    
    -- alts: Put all alt user IDs here
    alts = {
        2939174150,
        3281293170,
        3034352629,
        2827160867,
        7178503675,
    },
    
    -- Prefix: Enter the prefix before each command.
    Prefix = "/"
}

-- Loader: Loads the main script logic
loadstring(game:HttpGet("https://raw.githubusercontent.com/LS-AltControl/LS-Control/refs/heads/main/Loader.lua"))()

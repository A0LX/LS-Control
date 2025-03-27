# LS Alt Control
<h3>Thank you for choosing LS Alt Control.</h3>
<h4><a href="">Join the Discord Server!</a></h4>

<b>Commands:</b>

- **drop** ~ `/drop`  
  Starts dropping.

- **cdrop** ~ `/cdrop [(REQUIRED STRING) Amount, e.g., 100k - 3m]`  
  Starts dropping until the specified amount is reached on the ground.

- **stop** ~ `/stop`  
  Stops both drop and cdrop.

- **wallet** ~ `/wallet`  
  Equips or unequips the alt's wallet.

- **dropped** ~ `/dropped`  
  Tells you the current amount on the ground.

- **tp** ~ `/tp [(REQUIRED STRING) Location]`  
  Teleports the alt to the specified location.

- **tpf** ~ `/tpf [(REQUIRED STRING) Location]`  
  Teleports the alt to the specified location and freezes them.

- **airlock** ~ `/airlock [(OPTIONAL STRING) Height]`  
  Enables airlock (default height is 10 studs).

- **unairlock** ~ `/unairlock`  
  Disables airlock.

- **hide** ~ `/hide`  
  Moves the alt 10 studs underground.

- **spot** ~ `/spot`  
  Teleports the alt to the controller and freezes them.

- **line** ~ `/line`  
  Teleports the alts in a line behind the controller.

- **circle** ~ `/circle`  
  Teleports the alts in a circle around the controller.

- **bring** ~ `/bring [(REQUIRED STRING) User]`  
  Brings the specified user to the controller or location.

- **goto** ~ `/goto [(OPTIONAL STRING) User]`  
  Teleports the alt to the operator or specified user.

- **rejoin** ~ `/rejoin`  
  Makes the alt rejoin the server (requires proper permissions).

- **ad** ~ `/ad`  
  Starts advertising.

- **admsg** ~ `/admsg [(REQUIRED STRING) Message]`  
  Updates the advertisement message.

- **say** ~ `/say [(REQUIRED STRING) Message]`  
  Makes the alt chat a message.

<b>Alt Handling:</b>

Alts now automatically log themselves when the script is executed. The logging system is managed in a separate file (**AltLogger.lua**) that saves a JSON file (located in your local workspace folder) with each alt’s unique numerical ID. When multiple alts are in-game, they detect one another and dynamically sort by their registered IDs—ensuring that lower-numbered slots are always filled first.

<b>Locations:</b>

- **bank** ~ Bank (Central)
- **roof** ~ Bank roof (Central)
- **klub** ~ Klub (Central)

<b>Requirements:</b>

- **Web executors:** AWP, Wave, Mumu, or UG-phone (use autoexec because of anticheat restrictions).
- **Roblox Account Manager:** [Download here](https://github.com/ic3w0lf22/Roblox-Account-Manager/releases)

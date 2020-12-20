-- Import section
local playTune = require("play-tune")
--

local tune = {
  {pitch = "A4", duration = 0.1, wait = 0.0},
  {pitch = "A3", duration = 0.3, wait = 0.4},
  {pitch = "A4", duration = 0.1, wait = 0.0},
  {pitch = "A3", duration = 0.3, wait = 0.4},
  {pitch = "A4", duration = 0.1, wait = 0.0},
  {pitch = "A3", duration = 0.3, wait = 0.4},
  {pitch = "A4", duration = 0.1, wait = 0.0},
  {pitch = "A3", duration = 0.3, wait = 0.4}
}

return playTune(tune)

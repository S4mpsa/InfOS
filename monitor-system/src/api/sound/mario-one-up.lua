-- Import section
local playTune = require("api.sound.play-tune")
--

local tune = {
  "E5",
  "G5",
  "E6",
  "C6",
  "D6",
  "G6"
}

return playTune(tune)

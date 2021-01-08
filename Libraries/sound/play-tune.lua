-- Import section
Computer = require("computer")
local note = require("note")
--

local function playTune(tune)
  return function()
    for i, tone in ipairs(tune) do
      note.play(tone.pitch or tone, tone.duration or 0.1)
      os.sleep(tone.wait or 0.01)
    end
  end
end

return playTune

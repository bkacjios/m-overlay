local ffi = require("ffi")

local ffistring = ffi.string
local cdef = ffi.cdef

cdef [[
typedef uint8_t SAMPLE_8BIT;
typedef int16_t SAMPLE_16BIT;

typedef struct {
	unsigned char riff[4];                      // RIFF string
	unsigned int data_size;                     // overall size of file in bytes - 8
	unsigned char wave[4];                      // WAVE string
} WAV_HEADER;

typedef struct {
	unsigned char chunk_id[4];                  // RIFF string
	unsigned int chunk_size;                    // overall size of chunk in bytes
} WAV_CHUNK;

typedef struct {
	unsigned int id;
	unsigned int position;
	unsigned char data[4];
	unsigned int chunk_start;
	unsigned int block_start;
	unsigned int sample_offset;
} CUE_POINT;

typedef struct {
  unsigned int num_points;
  CUE_POINT points[];
} CUE_CHUNK;

typedef struct {
  unsigned int  id;
  unsigned int  type;
  unsigned int  sample_start;
  unsigned int  sample_end;
  unsigned int  fraction;
  unsigned int  play_count;
} SAMPLE_LOOP;

typedef struct {
  unsigned int manufacturer;
  unsigned int product;
  unsigned int sample_period;
  unsigned int midi_unity_note;
  unsigned int midi_pitch_fraction;
  unsigned int smpte_format;
  unsigned int smpte_offset;
  unsigned int sample_loops;
  unsigned int sample_data;
  SAMPLE_LOOP loops[];
} SAMPLE_CHUNK;
]]

local wav = {}

function wav.parse(file)
	local f = assert(love.filesystem.newFile(file, "r"))

	local parsed = {
		points = {},
		loops = {}
	}

	local header = ffi.cast("WAV_HEADER*", f:read(ffi.sizeof("WAV_HEADER")))

	while true do
		local chunk = ffi.cast("WAV_CHUNK*", f:read(ffi.sizeof("WAV_CHUNK")))

		local name = ffistring(chunk.chunk_id, 4):lower()
		local size = chunk.chunk_size

		if size <= 0 then break end -- EOF

		local data = f:read(chunk.chunk_size)

		if name == "cue " then
			local cue = ffi.cast("CUE_CHUNK*", data)
			for i=0, cue.num_points-1 do
				local point = cue.points[i]
				table.insert(parsed.points, {
					id = point.id,
					position = point.position,
					chunk_start = point.chunk_start,
					block_start = point.block_start,
					sample_offset = point.sample_offset
				})
			end
		elseif name == "smpl" then
			local smpl = ffi.cast("SAMPLE_CHUNK*", data)
			for i=0, smpl.sample_loops-1 do
				local loop = smpl.loops[i]
				table.insert(parsed.loops, {
					id = loop.id,
					type = loop.type,
					sample_start = loop.sample_start,
					sample_end = loop.sample_end,
					fraction = loop.fraction,
					play_count = loop.play_count
				})
			end
		elseif name == "data" then
			break -- Stop parsing wav file when encountering PCM data
		end
	end

	f:close()
	return parsed
end

return wav
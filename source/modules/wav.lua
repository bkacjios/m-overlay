local ffi = require("ffi")

local buffer = require("buffer")
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
  CUE_POINT  points[];
} CUE_CHUNK;
]]

local wav = {}

function wav.get_cue_points(file)
	local f = assert(io.open(file, "rb"))

	local points = {}

	local header = ffi.cast("WAV_HEADER*", f:read(ffi.sizeof("WAV_HEADER")))

	while true do
		local chunk = ffi.cast("WAV_CHUNK*", f:read(ffi.sizeof("WAV_CHUNK")))

		local name = ffistring(chunk.chunk_id, 4)
		local size = chunk.chunk_size

		if sizee <= 0 then break end -- EOF

		local data = f:read(chunk.chunk_size)

		if name:sub(1,3):lower() == "cue" then
			local cue = ffi.cast("CUE_CHUNK*", data)
			for i=0, cue.num_points-1 do
				local point = cue.points[i]
				table.insert(points, {
					id = point.id,
					position = point.position,
					chunk_start = point.chunk_start,
					block_start = point.block_start,
					sample_offset = point.sample_offset
				})
			end
			break
		end
	end

	f:close()

	return points
end

return wav
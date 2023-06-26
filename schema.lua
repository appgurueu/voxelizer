return {
	type = "table",
	entries = {
		max_precision = {
			type = "number",
			int = true,
			default = 15
		},
		download = {
			type = "boolean",
			default = false,
			description = "Whether to enable the `/vox download` chatcommand"
		},
		defaults = {
			type = "table",
			entries = {
				model = {
					type = "string",
					description = "Default model filename in world's media folder"
				},
				texture = {
					type = "string",
					description = "Default texture filename in world's media folder"
				},
				nodemap = {
					type = "string",
					description = "Default nodemap filename in world's media folder",
				},
				min_density = {
					type = "number",
					range = { min = 0, max = 1 },
					default = 0.1,
					description = "Minimum density default"
				},
				precision = {
					type = "number",
					range = { min = 1, max = 100 },
					int = true,
					default = 4,
					description = "Precision default"
				},
				dithering = {
					type = "number",
					range = { min = 1, max = 10 },
					int = true,
					default = 10,
					description = "Default dithering algorithm ID (see `/vox dithering`)"
				},
				placement = {
					type = "number",
					range = { min = 1, max = 3 },
					int = true,
					default = 1,
					description = "Default placement mode ID (see `/vox placement`)"
				},
				color_choosing = {
					type = "number",
					range = { min = 1, max = 2 },
					int = true,
					default = 1,
					description = "Default color choosing algorithm ID (see `/vox color_choosing`)"
				},
				filtering = {
					type = "number",
					range = { min = 1, max = 2 },
					int = true,
					default = 1,
					description = "Default filtering algorithm ID (see `/vox filtering`)"
				}
			}
		}
	}
}

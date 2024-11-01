IncludeScript("potatozi/misc.nut")

::PZI_NavMesh <- {
	ALL_AREAS = {},
	ISLANDS   = [],
	ISLAND_AREAS = {},
	IslandsParsed = false,

	// Simple Breadth First Search selecting all connected areas
	function FloodSelect(area, max_iters=5000)
	{
		if (!(area instanceof CTFNavArea)) return;

		local frontier = Queue();
		local reached  = {};

		frontier.add(area);
		reached[area] <- null;

		local iter = 0;
		while (!frontier.isEmpty())
		{
			if (iter >= max_iters)
				break;

			local current = frontier.pop();
			for (local i = 0; i < 4; ++i)
			{
				local buf = {};
				current.GetAdjacentAreas(i, buf);

				foreach (a in buf)
				{
					if (!(a in reached))
					{
						frontier.add(a);
						reached[a] <- null;
					}
				}
			}
			++iter;
		}

		return reached;
	},

	// Simple Breadth First Search with multiple start points
	function MultiFloodSelect(areas, max_iters=5000)
	{
		local data = {};
		foreach (area in areas)
		{
			if (!(area instanceof CTFNavArea)) return;
			data[area] <- { frontier=Queue(), reached={} };

			data[area].frontier.add(area);
			data[area].reached[area] <- null;
		}

		for (local i = 0; i < max_iters; ++i)
		{
			local finished = true;
			foreach (area, d in data)
			{
				if (d.frontier.isEmpty()) continue;
				finished = false;

				local current = d.frontier.pop();
				for (local i = 0; i < 4; ++i)
				{
					local buf = {};
					current.GetAdjacentAreas(i, buf);

					foreach (a in buf)
					{
						local reached = false;
						foreach (area, d in data)
						{
							if (a in d.reached)
							{
								reached = true;
								break;
							}
						}
						if (!reached)
						{
							d.frontier.add(a);
							d.reached[a] <- null;
						}
					}
				}
			}

			if (finished) break;
		}

		local reached = {};
		foreach (area, d in data)
			reached[area] <- d.reached;

		return reached;
	},

	function GetRandomArea(areas, spawnpoint=false)
	{
		local max_iters = 50;

		for (local j = 0; j < max_iters; ++j)
		{
			local index = RandomInt(0, areas.len() - 1);
			local i = 0;

			foreach (k, v in areas)
			{
				if (i < index)
				{
					++i;
					continue;
				}

				// Islands store areas as {area=null},
				// but NavMesh methods store as {"area<num>"=area}
				local a = (k instanceof CTFNavArea) ? k : v;

				if (!spawnpoint)
					return a;
				else
				{
					local center = a.GetCenter();
					local trace = {
						start   = center,
						end     = center + Vector(0, 0, 128),
						hullmin = Vector(-32, -32, 0),
						hullmax = Vector(32, 32, 0),
						mask    = 33636363 // MASK_PLAYERSOLID
					};
					TraceHull(trace);
					if ("hit" in trace && trace.hit)
						continue;
					else
						return a;
				}
			}
		}
	}
};
__CollectGameEventCallbacks(PZI_NavMesh);

NavMesh.GetAllAreas(PZI_NavMesh.ALL_AREAS);
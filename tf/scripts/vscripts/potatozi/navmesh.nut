IncludeScript("potatozi/misc.nut")

::PZI_NavMesh <- {
	ALL_AREAS = {},
	ISLANDS   = [],
	ISLANDS_PARSED = false,

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
};
__CollectGameEventCallbacks(PZI_NavMesh);

NavMesh.GetAllAreas(PZI_NavMesh.ALL_AREAS);
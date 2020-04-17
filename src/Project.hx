package;

import ceramic.InitSettings;
import ceramic.Entity;

class Project extends Entity {
	function new(settings:InitSettings) {
        super();

		#if SNIPPET_DRAW
		new snippets.DrawALine(settings);
		#else
		new TableVariableProject(settings);
        #end
    }
}

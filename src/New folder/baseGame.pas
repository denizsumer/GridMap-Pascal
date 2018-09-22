//zoom in zoom out???
//swin splash
//worst game splash
//mouse cursors
//full screen and borderless option
//menu and exit button

program Basement;
uses SwinGame, sgTypes, sgPhysics, sysUtils,
	baseTypes, baseInitialise, baseInput;

const
	GRIDWIDTH = 150;
	GRIDHEIGHT = 75;
	GRIDHALF = 37.5;

procedure DrawRadar(var game: GameData);
var
	camposXToZero, camposYToZero: Single;
	mapRadarXRatio, mapRadarYRatio: Single;
begin
	///CALCULATIONS TO MATCH MAPSIZE TO RADAR RATIO///
	camposXToZero := game.campos.x + (game.base.mapWidth / 2) - GRIDHEIGHT + 125;
	camposYToZero := game.campos.y + 125;
	mapRadarXRatio := (game.base.mapWidth - ScreenWidth() + 250) / 210;
	mapRadarYRatio := (game.base.mapHeight - ScreenHeight() + 250) / 110;

	///DRAWS SMALL SCALE MAP ON THE LEFT TOP///
	game.radar.x := 1000 + (camposXToZero / mapRadarXRatio);
	game.radar.y := 20 + (camposYToZero / mapRadarYRatio) ;
	DrawBitmap('radar', 1005, 25);
	DrawRectangle(colorRed, game.radar.x, game.radar.y, 50, 25);
end;

procedure DrawGrid(var grid: Grid; var game: GameData);
begin
	grid.pos.x := ((grid.column - grid.row) * GRIDHEIGHT) - game.campos.x;
	grid.pos.y := ((grid.row + grid.column) * GRIDHALF) - 75 - game.campos.y;

	///DRAWS GRID BITMAPS FOR NORMAL, CURSOR ON IT AND SELECTED///
	if grid.selected = false then DrawBitmap('base', grid.pos.x, grid.pos.y);
	if grid.onCursor = true then DrawBitmap('cursorBase', grid.pos.x, grid.pos.y);
	if grid.selected = true then DrawBitmap('selectedBase', grid.pos.x, grid.pos.y);
end;

procedure DrawGame(game: GameData);
var
	i: Integer;
begin
	///DRAW GRIDS///
	for i := 0 to High(game.base.grids) do
	begin
		game.base.grids[i].id := i + 1 ;
		game.base.grids[i].row := trunc((game.base.grids[i].id -1) / game.base.MapDivider) + 1;
		game.base.grids[i].column := (game.base.grids[i].id mod game.base.MapDivider);
		if game.base.grids[i].column = 0 then game.base.grids[i].column := game.base.MapDivider;
		DrawGrid(game.base.grids[i], game);
	end;
	///DRAW RADAR///
	DrawRadar(game);
end;

procedure Main();
var
	game: GameData;
begin
	InitialiseGame(game);
	repeat
		ProcessEvents();
	 	RefreshScreen(60);
	 	ClearScreen(colorGreen);
	 	DrawGame(game);
	 	UserInputs(game);
	 	DevMode(game);
	until WindowCloseRequested();
end;

begin
	Main();
end.

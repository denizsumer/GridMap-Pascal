unit wrstGames;

interface
uses sgTypes;
//

procedure ShowWorstGamesSplashScreen();
//
//

implementation
//=============================================================================

  uses Math, Classes, SysUtils, // system
       sgTrace, sgGraphics,
       sgCamera, sgShared, sgGeometry, sgResources, sgImages, sgUtils, sgDriverGraphics, sgDriver, sgDriverImages, sgInput, sgAudio, sgText, sgAnimations, sgDrawingOptions,
       sgInputBackend, sgBackendTypes, sgWindowManager, sgDriverSDL2Types;


procedure ShowWorstGamesSplashScreen();
    var
        aniX, aniY, txtX, txtY : LongInt;
        i: Longint;
        f: Font;
        txt: String;
        //oldW, oldH: Longint;
        //isStep: Boolean;
        isPaused: Boolean;
        isSkip: Boolean;
        startAni: Animation;
        aniBmp: sgTypes.Bitmap;
        
        procedure InnerProcessEvents();
        begin
            ProcessEvents();
            if (KeyDown(sgTypes.SuperKey) or KeyDown(sgTypes.CtrlKey)) and KeyTyped(PKey) then
            begin
                isPaused := not isPaused;
            end;
            if WindowCloseRequested() or KeyDown(sgTypes.EscapeKey) then isSkip := true;
        end;
    begin

        isPaused := false;
        isSkip := false;
        
        {$IFDEF TRACE}
            TraceEnter('sgGraphics', 'ShowSwinGameSplashScreen');
        {$ENDIF}
        try
            ClearScreen(ColorWhite);
            RefreshScreen();
            try
                //oldW := ScreenWidth();
                //oldH := ScreenHeight();
                //if (oldW <> 800) or (oldH <> 600) then ChangeScreenSize(800, 600);
                // ToggleWindowBorder();
                
                LoadResourceBundle('splash.txt', False);
                
                i := 1;
                while isPaused or (i < 120) do
                begin
                    aniBmp := BitmapNamed('Swinburne');
                    aniX := (ScreenWidth() - BitmapCellWidth(aniBmp)) div 2;
                    aniY := (ScreenHeight() - BitmapCellHeight(aniBmp)) div 2;
                    
                    ClearScreen(ColorWhite);
                    sgImages.DrawBitmap(aniBmp, aniX, aniY);

                    f := FontNamed('SwinGameText');
                    txt := 'SwinGame API by Swinburne University of Technology';
                    txtX := (ScreenWidth() - TextWidth(f, txt)) div 2;
                    txtY := aniY + (ScreenHeight() - aniY + BitmapCellHeight(aniBmp)) div 2;

                    if txtY > aniY+ BitmapCellHeight(aniBmp) then DrawText(txt, ColorBlack, f, txtX, txtY );

                    f := FontNamed('LoadingFont');
                    DrawText(DLL_VERSION, ColorLightGrey, f, 5, ScreenHeight() - TextHeight(f, DLL_VERSION) - 2);
                    
                    i += 1;
                    InnerProcessEvents();
                    RefreshScreen(60);
                    if isSkip then break;
                end;
                
                aniBmp := BitmapNamed('swinburne');
                aniX := (ScreenWidth() - BitmapCellWidth(aniBmp)) div 2;
                aniY := (ScreenHeight() - BitmapCellHeight(aniBmp)) div 2;
                
                {$IFDEF TRACE}
                    startAni := CreateAnimation('splash-debug', AnimationScriptNamed('Startup'));
                {$ELSE}
                    startAni := CreateAnimation('splash', AnimationScriptNamed('Startup'));
                {$ENDIF}
                while not AnimationEnded(startAni) do
                begin
                    ClearScreen(ColorWhite);
                    
                    DrawAnimation(startAni, aniBmp, aniX, aniY);
                    UpdateAnimation(startAni);
                    
                    RefreshScreen();
                    InnerProcessEvents();
                    if isSkip then break;
                    Delay(15);
                end;
                ClearScreen(ColorWhite);
                RefreshScreen();
                
                while SoundEffectPlaying(SoundEffectNamed('SwinGameStart')) or isPaused do
                begin
                    InnerProcessEvents();
                    if isSkip then break;
                end;
                
                StopSoundEffect('SwinGameStart');

                // i := 1;
                // while isPaused or (i < 30) do
                // begin
                //     i += 1;
                    
                //     InnerProcessEvents();
                //     RefreshScreen(60);
                //     if isSkip then break;
                // end;
            except on e:Exception do
                {$IFDEF TRACE}
                begin
                    Trace('sgGraphics', 'Error', 'ShowSwinGameSplashScreen', 'Error loading and drawing splash.');
                    Trace('sgGraphics', 'Error', 'ShowSwinGameSplashScreen', e.Message);
                end;
                {$ENDIF}
            end;
        finally
            try
                ReleaseResourceBundle('splash.txt');
            except on e1: Exception do
                begin
                    RaiseWarning('Error releating splash resources.');
                    {$IFDEF TRACE}
                        Trace('sgGraphics', 'Error', 'ShowSwinGameSplashScreen', 'Error freeing splash.');
                        Trace('sgGraphics', 'Error', 'ShowSwinGameSplashScreen', e1.Message);
                    {$ENDIF}
                 end;
            end;
            // ToggleWindowBorder();
            
            //if (oldW <> 800) or (oldH <> 600) then ChangeScreenSize(oldW, oldH);
        end;
        
        {$IFDEF TRACE}
            TraceExit('sgGraphics', 'ShowSwinGameSplashScreen');
        {$ENDIF}
    end;


initialization
begin
    InitialiseSwinGame();

end;

finalization
begin


end;

end.

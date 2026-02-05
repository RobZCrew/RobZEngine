package funkin.menus.ui;

/**
 * Helper screen that shows a help text.
 *
 * @author RobZ
 * @since 0.1.0
 */
class HelperScreen extends MusicBeatSubstate {
    public static var helpers:Map<Class<MusicBeatState>, String> = [
        OptionsMenu => 'UP - Select other option up\n' +
        'DOWN - Select other option down\n' +
        'LEFT - Select other tab left\n' +
        'RIGHT - Select other tab right'
    ];
    public var helperBackground:FlxSprite;
    public var helperText:FlxText;

    public function new(state:Class<MusicBeatState>):Void {
        super();

        helperBackground = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        helperBackground.alpha = 0.5;
        add(helperBackground);

        helperText = new FlxText(0, 0, FlxG.width, (helpers.exists(state) ? helpers.get(state) : 'No help available for this state'));
        helperText.setFormat(null, 30, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.TRANSPARENT);
        helperText.screenCenter();
        add(helperText);
    }

    override function update(elapsed:Float):Void {
        super.update(elapsed);
        if (controls.BACK) close();
    }
}
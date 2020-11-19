package skija;

import org.eclipse.swt.events.PaintEvent;
import java.io.ByteArrayInputStream;
import org.eclipse.swt.SWT;
import org.eclipse.swt.widgets.*;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.widgets.Canvas;
import org.eclipse.swt.layout.*;
import org.jetbrains.skija.*;
import swt.callbacks.*;

class Main {
    public static function main() {
        var display = new Display ();
        var shell = new Shell (display);
        shell.setText("Skija");
        shell.setLayout(new FillLayout(SWT.VERTICAL));

        var canvas = new Canvas(shell, SWT.NONE);

        canvas.addPaintListener(new PaintCallback({
            paintControl: (e: PaintEvent) -> {
                    var surface = Surface.makeRasterN32Premul(e.width, e.height);
                    var canvas = surface.getCanvas();
                    var background = new Paint();
                    background.setColor(0xFFFFFFFF);
                    var paint = new Paint();
                    paint.setColor(0xFF0000FF);
                    canvas.drawRect(Rect.makeXYWH(e.x, e.y, e.width, e.height), background);
                    var radius: Float;
                    if (e.width < e.height) 
                        radius = e.width / 2;
                    else {
                        radius = e.height / 2;
                    } 

                    canvas.drawCircle(e.width/2, e.height/2, radius, paint);

                    var image = surface.makeImageSnapshot();
                    var pngData = image.encodeToData(EncodedImageFormat.JPEG);
                    var pngBytes = pngData.getBytes();
                    var x = new Image(display, new ByteArrayInputStream(pngBytes));

                    e.gc.drawImage(x, 0, 0);

                    x.dispose();
                }
            })
        );


        shell.setSize(200, 200);
        shell.open();

        while (!shell.isDisposed()) {
            if (!display.readAndDispatch ()) display.sleep ();
        }
        display.dispose ();
    }
}

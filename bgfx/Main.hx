package bgfx;

import haxe.Int64;
import org.eclipse.swt.events.PaintEvent;
import java.io.ByteArrayInputStream;
import org.eclipse.swt.SWT;
import org.eclipse.swt.widgets.*;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.widgets.Canvas;
import org.eclipse.swt.layout.*;
import org.lwjgl.system.*;
import org.lwjgl.glfw.GLFW.*;
import org.lwjgl.glfw.*;
import org.lwjgl.*;
import org.lwjgl.bgfx.BGFX.*;
import org.lwjgl.bgfx.BGFXInit;
import org.lwjgl.bgfx.BGFXPlatform.*;
import org.lwjgl.bgfx.BGFXPlatformData;
import org.lwjgl.bgfx.BGFXResolution;
import org.lwjgl.system.MemoryUtil.*;
 
import org.eclipse.swt.internal.cocoa.*;
import swt.callbacks.*;

class Main {
    public static function main() {
        var width = 1024;
        var height = 720;
        var display = new Display ();

        var shell = new Shell (display);
        shell.setText("BGFX");
        shell.setLayout(new FillLayout(SWT.FILL));

        var composite = new Composite(shell, SWT.NONE);
        composite.setBackground(display.getSystemColor(SWT.COLOR_BLUE));
        composite.setLocation(0, 0);

        if (!glfwInit())
            throw ("Unable to initialize GLFW");

        glfwWindowHint(GLFW_DECORATED, GLFW_FALSE);
        glfwWindowHint(GLFW_VISIBLE, GLFW_FALSE);
        glfwWindowHint(GLFW_CLIENT_API, GLFW_NO_API);
        glfwWindowHint(GLFW_COCOA_RETINA_FRAMEBUFFER, GLFW_FALSE);
        var window = glfwCreateWindow(200, 200, "", 0, 0);
        var windowId = GLFWNativeCocoa.glfwGetCocoaWindow(window);
        var testWindow = new NSWindow(windowId);
        var nswindow = shell.view.window();
        nswindow.addChildWindow(testWindow, OS.NSWindowAbove);
    
        // new LongRunningOperation(display, window, windowId, width, height).start();
        var stack = MemoryStack.stackPush();
        var init = BGFXInit.mallocStack(stack);
        bgfx_init_ctor(init);
        var res = BGFXResolution.mallocStack(stack);
        res.width(width);
        res.height(height);
        res.reset(BGFX_RESET_VSYNC);
        init.resolution(res);
        init.callback(null);
        init.allocator(null);

        //At least for osx you must render a frame before calling bgfx_init
        bgfx_render_frame(16);
        init.platformData().nwh(windowId);
        if (!bgfx_init(init)) {
            throw ("Error initializing bgfx renderer");
        }

        var format = init.resolution().format();

        bgfx_set_debug(BGFX_DEBUG_TEXT);

        bgfx_set_view_clear(0, BGFX_CLEAR_COLOR | BGFX_CLEAR_DEPTH, 0x303030ff, 1.0, 0);

        display.asyncExec(
            new SWTRunnable( () -> {
                while (!shell.isDisposed()) {
                    glfwPollEvents();
                    // Set view 0 default viewport.
                    bgfx_set_view_rect(0, 0, 0, width, height);

                    // This dummy draw call is here to make sure that view 0 is cleared
                    // if no other draw calls are submitted to view 0.
                    bgfx_touch(0);

                    // Use debug font to print information about this example.
                    bgfx_dbg_text_clear(0, false);
                 
                    bgfx_dbg_text_printf(0, 1, 0x1f, "bgfx/examples/25-c99");
                    bgfx_dbg_text_printf(0, 2, 0x3f, "Description: Debug text.");

                    bgfx_dbg_text_printf(0, 3, 0x0f, "Color can be changed with ANSI \u001b[9;me\u001b[10;ms\u001b[11;mc\u001b[12;ma\u001b[13;mp\u001b[14;me\u001b[0m code too.");

                    bgfx_dbg_text_printf(0, 4, 0x0f, "\u001b[;0m    \u001b[;1m    \u001b[; 2m    \u001b[; 3m    \u001b[; 4m    \u001b[; 5m    \u001b[; 6m    \u001b[; 7m    \u001b[0m");
                    bgfx_dbg_text_printf(0, 5, 0x0f, "\u001b[;8m    \u001b[;9m    \u001b[;10m    \u001b[;11m    \u001b[;12m    \u001b[;13m    \u001b[;14m    \u001b[;15m    \u001b[0m");
                    bgfx_dbg_text_printf(0, 6, 0x0f, "BGFX In SWT!");

                    // Advance to next frame. Rendering thread will be kicked to
                    // process submitted rendering primitives.
                    bgfx_frame(false);
                }
                bgfx_shutdown();
                glfwDestroyWindow(window);
                glfwTerminate();
            })
        ); 

        shell.addListener(SWT.Resize, new ListenerCallback( {
            handleEvent: 
                e -> {
                    var size = composite.getSize(); 
                    width = size.x;
                    height = size.y; 
                    glfwSetWindowSize(window, size.x, size.y);
                    var displayLocation = composite.toDisplay(0, 0);
                    glfwSetWindowPos(window, displayLocation.x, displayLocation.y);
                    bgfx_reset(size.x, size.y, BGFX_RESET_VSYNC, format);
                }
        }));

        shell.setSize(width, height);
        shell.open();

        while (!shell.isDisposed()) {
            if (!display.readAndDispatch ()) display.sleep ();
           
        }
        display.dispose ();
    }
}

class SWTRunnable implements java.lang.Runnable {
    var msg:String;
    var callback: Void -> Void;
	public function new(callback: Void -> Void):Void {
        this.callback = callback;
	}
	public function run():Void {
        callback();
	}
}

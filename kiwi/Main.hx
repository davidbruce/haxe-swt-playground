package kiwi;

import swt.callbacks.ListenerCallback;
import org.eclipse.swt.*;
import org.eclipse.swt.widgets.*;
import jasper.*;

class GlobalSolver {  
    public static final instance:Solver = new Solver();
    private function new () {} 
}

class Rectangle
{
    public var x: Variable;
    public var y: Variable;
    public var width: Variable;
    public var height: Variable;
    public var control: Control;

    public function new(control: Control): Void
    {
        this.control = control;
        x = new Variable();
        y = new Variable();
        width = new Variable();
        height = new Variable();
    }

    public function render() : Void
    {
        trace(width);
        trace(height);
        this.control.setBounds(cast(x.m_value, Int),cast(y.m_value, Int), cast(width.m_value, Int), cast(height.m_value, Int));
        this.control.moveAbove(null);
    }
}

class Main {
    public static function main() {
	    var display = new Display ();
        var shell = new Shell (display);
        shell.setText("Constraints");

        var solver = new Solver();
        var window = new Rectangle(new Composite(shell, SWT.NONE));
        solver.addConstraint(window.x == 0);
        solver.addConstraint(window.y == 0);

        var main = new Rectangle(new Button(shell, SWT.PUSH));
        solver.addConstraint(main.x == 10);
        solver.addConstraint(main.y == 10);
        solver.addConstraint((main.width == window.width - 20) | Strength.REQUIRED);
        solver.addConstraint((main.height == window.height - 20) | Strength.REQUIRED);

        solver.addConstraint((main.width <= window.width - 20) | Strength.REQUIRED);
        solver.addConstraint((main.height <= window.height - 20) | Strength.REQUIRED);
        solver.addConstraint((main.width >= 50) | Strength.REQUIRED);
        solver.addConstraint((main.height >= 50) | Strength.REQUIRED);

        var leftChild = new Rectangle(new Button(shell, SWT.PUSH));
        solver.addConstraint(leftChild.x == main.x + 10);
        solver.addConstraint(leftChild.y == main.y + 10);
        solver.addConstraint(leftChild.width == (main.width/2 - 20));
        solver.addConstraint(leftChild.height == (main.height - 20));

        var rightChild = new Rectangle(new Button(shell, SWT.PUSH));
        solver.addConstraint(rightChild.x == (main.x + main.width) - (main.width/2 - 10));
        solver.addConstraint(rightChild.y == main.y + 10);
        solver.addConstraint(rightChild.width == (main.width/2 - 20));
        solver.addConstraint(rightChild.height == (main.height - 20));

        var centerChild = new Rectangle(new Button(shell, SWT.PUSH));
        solver.addConstraint(centerChild.x == main.x + main.width/4);
        solver.addConstraint(centerChild.y == main.y + main.height/4);
        solver.addConstraint(centerChild.width == (main.width/2));
        solver.addConstraint(centerChild.height == (main.height/2));

        solver.updateVariables();
        solver.addEditVariable(window.width, Strength.WEAK);
        solver.addEditVariable(window.height, Strength.WEAK);


        var render = () -> {
            main.render();
            rightChild.render();
            leftChild.render();
            centerChild.render();
        }

        render();
        shell.addListener(SWT.Resize, new ListenerCallback( {
            handleEvent: e -> {
                var size = shell.getClientArea(); 
                solver.suggestValue(window.width, size.width);
                solver.suggestValue(window.height, size.height);
                solver.updateVariables();
                render();
            }
        }));

        shell.setSize(200, 200);
        shell.open();
        while (!shell.isDisposed()) {
            if (!display.readAndDispatch ()) display.sleep ();
        }
        display.dispose ();
    }

}

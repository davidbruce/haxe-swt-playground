package kiwi;

import org.eclipse.swt.graphics.Rectangle;
import org.eclipse.swt.*;
import org.eclipse.swt.widgets.*;
import jasper.*;
import swt.callbacks.ListenerCallback;

/*
#Component
app = new Window({    
    title:  "Slider",
    layout: [ 
        {
            content: { 
                constraints: fill
            },
            addButton: { 
                constraints: [x == 75%, y == 75%, width == 20, height == 20]
            }
        }
    ],
    children:
         [
            content => new Container({
                layout: [
                   { 
                       hbox: [left, slider, right]
                       margins: 1
                   }
                ]
                children: [
                    left => {},
                    right => {},
                    slider => new Sash({
                        border: true,
                        events: [ Drag ]
                    })
                ]
            }),
            addButton => new Button ({
                events: [ Click ]
            })
        ]
    }
)
*/


class Component { 
    public var control: Control;
    public var x: Variable;
    public var y: Variable;
    public var width: Variable;
    public var height: Variable;
    public var padding: Rectangle;
    public var margin: Rectangle;
    public var zindex: Int;

    public function new(control: Control): Void {
        this.control = control;
        x = new Variable();
        y = new Variable();
        width = new Variable();
        height = new Variable();
        padding = new Rectangle(0, 0, 0, 0);
        margin = new Rectangle(0, 0, 0, 0);
        zindex = 0;
    }

    public function draw(): Void {
        this.control.setBounds(cast(x.m_value, Int),cast(y.m_value, Int), cast(width.m_value, Int), cast(height.m_value, Int));
        this.control.moveAbove(null);
    }
}

class Container extends Component {
    public var solver(default, null) = new Solver();
    public var children(default, null) = new Array<Component>(); 
    public function new(control: Control) {
        super(control);
    }

    override public function draw(): Void {
        super.draw();
        for (component in children) {
            component.draw();
        }
    }

    public function add(component: Component) {
        children.push(component);
        // children.sort((a, b) -> a.zindex - b.zindex);
    }
}

class Main {
    public static function main() {
	    var display = new Display ();
        var shell = new Shell (display);
        shell.setText("Constraints");

        var window = new Container(new Composite(shell, SWT.NONE));
        var solver = window.solver;
        solver.addConstraint(window.x == 0);
        solver.addConstraint(window.y == 0);

        var main = new Component(new Button(shell, SWT.PUSH));
        solver.addConstraint(main.x == 10);
        solver.addConstraint(main.y == 10);
        solver.addConstraint((main.width == window.width - 20) | Strength.REQUIRED);
        solver.addConstraint((main.height == window.height - 20) | Strength.REQUIRED);

        solver.addConstraint((main.width <= window.width - 20) | Strength.REQUIRED);
        solver.addConstraint((main.height <= window.height - 20) | Strength.REQUIRED);
        solver.addConstraint((main.width >= 50) | Strength.REQUIRED);
        solver.addConstraint((main.height >= 50) | Strength.REQUIRED);

        var leftChild = new Component(new Button(shell, SWT.PUSH));
        solver.addConstraint(leftChild.x == main.x + 10);
        solver.addConstraint(leftChild.y == main.y + 10);
        solver.addConstraint(leftChild.width == (main.width/2 - 20));
        solver.addConstraint(leftChild.height == (main.height - 20));

        var rightChild = new Component(new Button(shell, SWT.PUSH));
        solver.addConstraint(rightChild.x == (main.x + main.width) - (main.width/2 - 10));
        solver.addConstraint(rightChild.y == main.y + 10);
        solver.addConstraint(rightChild.width == (main.width/2 - 20));
        solver.addConstraint(rightChild.height == (main.height - 20));

        var centerChild = new Component(new Button(shell, SWT.PUSH));
        solver.addConstraint(centerChild.x == main.x + main.width/4);
        solver.addConstraint(centerChild.y == main.y + main.height/4);
        solver.addConstraint(centerChild.width == (main.width/2));
        solver.addConstraint(centerChild.height == (main.height/2));

        solver.updateVariables();
        solver.addEditVariable(window.width, Strength.STRONG);
        solver.addEditVariable(window.height, Strength.STRONG);


        window.add(main);
        window.add(leftChild);
        window.add(rightChild);
        window.add(centerChild);

        window.draw();
        shell.addListener(SWT.Resize, new ListenerCallback( {
            handleEvent: 
                e -> {
                    var size = shell.getClientArea(); 
                    solver.suggestValue(window.width, size.width);
                    solver.suggestValue(window.height, size.height);
                    solver.updateVariables();
                    window.draw();
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

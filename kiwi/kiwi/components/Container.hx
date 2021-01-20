package kiwi.components;
import org.eclipse.swt.widgets.Control;
import jasper.Solver;

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


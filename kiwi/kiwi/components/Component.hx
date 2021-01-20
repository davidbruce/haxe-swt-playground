package kiwi.components;
import org.eclipse.swt.widgets.*;
import org.eclipse.swt.graphics.Rectangle;
import jasper.*;

class Component { 
    public var control: Control;
    public var x: Variable;
    public var y: Variable;
    public var width: Variable;
    public var height: Variable;
    public var padding: Rectangle;
    public var margin: Rectangle;
    public var zindex: Int; //this should be part of a container

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
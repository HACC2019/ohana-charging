public class Event{
    public double time;        //Time at which Event takes place
    public int type;           //Type of Event
    public Event next;         //Points to next event in list
    
    public Event(double t, int i){
        time = t;
        type = i;
        next = null;
    }
}
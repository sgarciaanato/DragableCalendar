//
//  CalendarViewController.swift
//  DragableCalendar
//
//  Created by Samuel on 21-01-18.
//  Copyright © 2018 Samuel. All rights reserved.
//

import UIKit

class CalendarViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var arrayViews = Array<UIView>()
    var arrayPerson = ["Person 1","Person 2","Person 3","Person 4","Person 5","Person 6","Person 7","Person 8","Person 9","Person 10","Person 11","Person 12","person 13"]
    var beginPoint = CGPoint(x: 0, y: 0)
    
    @IBOutlet weak var personTableView: UITableView!
    @IBOutlet weak var calendarView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
        
        personTableView.register(UINib(nibName: "PersonTableViewCell", bundle: nil), forCellReuseIdentifier: "PersonTableViewCell")
        
        personTableView.delegate = self
        personTableView.dataSource = self
        
        let longpress = UILongPressGestureRecognizer(target: self, action: #selector(longPressGestureRecognized))
        personTableView.addGestureRecognizer(longpress)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
    }
    
    @objc func addTapped(){
        let alert = UIAlertController(title: "Crea una tarea",
                                      message: nil,
                                      preferredStyle: .alert)
        
        let createAction = UIAlertAction(title: "Crear", style: .default, handler: { (action) -> Void in
            // Get TextFields text
            let nameTxt = alert.textFields![0].text
            let label = UILabel(frame: CGRect(x: 106, y: 20, width: 108, height: 38))
//            textView.setValue(1, forKey: "x")
//            textView.setValue(1, forKey: "y")
            label.numberOfLines = 0
            label.adjustsFontSizeToFitWidth = true
            label.minimumScaleFactor = 0.5
            label.text = nameTxt
            label.backgroundColor = UIColor.blue.withAlphaComponent(0.4)
            
            var available = false
            while available == false{
                if(self.arrayViews.count == 0){
                    available = true
                }
                available = true
                for view in self.arrayViews{
                    if view.frame.origin == label.frame.origin{
                        available = false
                    }
                }
                if available == true{
                    self.arrayViews.append(label)
                    self.calendarView.addSubview(label)
                    let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.draggedView(_:)))
                    label.tag = self.arrayViews.count
                    label.isUserInteractionEnabled = true
                    label.addGestureRecognizer(panGesture)
                    
                }else{
                    label.frame.origin.x += 108
                    if(label.frame.origin.x + label.frame.width > self.calendarView.frame.size.width){
                        label.frame.origin.x = 106
                        label.frame.origin.y += 38
                    }
                }
            }
            
        })
        
        let cancel = UIAlertAction(title: "Cancelar", style: .destructive, handler: { (action) -> Void in })
        
        alert.addTextField { (textField: UITextField) in
            textField.keyboardType = .default
            textField.autocorrectionType = .default
            textField.placeholder = "Escribe su nombre"
        }
        alert.addAction(createAction)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
        
    }
    
    @objc func draggedView(_ sender:UIPanGestureRecognizer){
        if(sender.state == .began){
            beginPoint = (sender.view?.frame.origin)!
        }
        calendarView.bringSubview(toFront: sender.view!)
        let translation = sender.translation(in: calendarView)
        sender.view?.center = CGPoint(x: (sender.view?.center.x)! + translation.x, y: (sender.view?.center.y)! + translation.y)
        sender.setTranslation(CGPoint.zero, in: calendarView)
        if(sender.state == .ended){
            var available = true
            for view in arrayViews{
                if(sender.view?.tag != view.tag && (sender.view?.center.x)! > view.frame.origin.x && (sender.view?.center.x)! < view.frame.origin.x + view.frame.size.width
                    && (sender.view?.center.y)! > view.frame.origin.y && (sender.view?.center.y)! < view.frame.origin.y + view.frame.size.height){
                    available = false
                }
            }
            if !available{
                sender.view?.frame.origin = beginPoint
            }else{
                for i in 0...8{
                    for j in 0...12{
                        if((sender.view?.center.x)! > CGFloat(106 + (108 * i)) && (sender.view?.center.x)! < CGFloat(106 + (108 * (i + 1)))
                            && (sender.view?.center.y)! > CGFloat(20 + (38 * j)) && (sender.view?.center.y)! < CGFloat(20 + (38 * (j + 1)))){
                            
                            sender.view?.frame.origin = CGPoint(x: CGFloat(106 + (108 * i)), y: CGFloat(20 + (38 * j)))
                            
                        }
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayPerson.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PersonTableViewCell", for: indexPath) as! PersonTableViewCell
        
        cell.selectionStyle = .none
        cell.name.text = arrayPerson[indexPath.row]
        
        return cell
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func longPressGestureRecognized(gestureRecognizer: UIGestureRecognizer) {
        let longPress = gestureRecognizer as! UILongPressGestureRecognizer
        let state = longPress.state
        let locationInView = longPress.location(in: personTableView)
        var indexPath = personTableView.indexPathForRow(at: locationInView)
        
        switch state {
        case UIGestureRecognizerState.began:
            if indexPath != nil {
                Path.initialIndexPath = indexPath as! NSIndexPath
                let cell = personTableView.cellForRow(at: indexPath!) as! PersonTableViewCell!
                My.cellSnapshot  = snapshopOfCell(inputView: cell!)
                var center = cell?.center
                My.cellSnapshot!.center = center!
                My.cellSnapshot!.alpha = 0.0
                personTableView.addSubview(My.cellSnapshot!)
                
                UIView.animate(withDuration: 0.25, animations: { () -> Void in
                    center?.y = locationInView.y
                    My.cellSnapshot!.center = center!
                    My.cellSnapshot!.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                    My.cellSnapshot!.alpha = 0.98
                    cell?.alpha = 0.0
                    
                }, completion: { (finished) -> Void in
                    if finished {
                        cell?.isHidden = true
                    }
                })
            }
        case .changed:
            var center = My.cellSnapshot!.center
            center.y = locationInView.y
            My.cellSnapshot!.center = center
            if ((indexPath != nil) && (indexPath  as! NSIndexPath != Path.initialIndexPath)) {
                swap(&arrayPerson[indexPath!.row], &arrayPerson[Path.initialIndexPath!.row])
                personTableView.moveRow(at: Path.initialIndexPath as! IndexPath , to: indexPath!)
                for view in arrayViews{
                    let n = Path.initialIndexPath as! IndexPath
                    if(view.frame.origin.y == CGFloat(20 + (38 * n.row))){
                        view.frame.origin.y = 0.0
                    }
                    let m = indexPath!
                    if(view.frame.origin.y == CGFloat(20 + (38 * m.row))){
                        view.frame.origin.y = CGFloat(20 + (38 * n.row))
                    }
                    if(view.frame.origin.y == 0.0){
                        view.frame.origin.y = CGFloat(20 + (38 * m.row))
                    }
                }
                Path.initialIndexPath = indexPath as! NSIndexPath
            }
        case .ended:
            if(indexPath  as! NSIndexPath == Path.initialIndexPath){
                personTableView.reloadData()
            }
            let cell = personTableView.cellForRow(at: indexPath!) as! PersonTableViewCell!
            cell?.isHidden = false
            My.cellSnapshot!.removeFromSuperview()
        case .cancelled:
            let cell = personTableView.cellForRow(at: indexPath!) as! PersonTableViewCell!
            cell?.isHidden = false
            My.cellSnapshot!.removeFromSuperview()
        case .failed:
            let cell = personTableView.cellForRow(at: indexPath!) as! PersonTableViewCell!
            cell?.isHidden = false
            My.cellSnapshot!.removeFromSuperview()
            
        default:
            break
        }
    }
    
    struct My {
        static var cellSnapshot : UIView? = nil
    }
    struct Path {
        static var initialIndexPath : NSIndexPath? = nil
    }
    
    func snapshopOfCell(inputView: UIView) -> UIView {
        UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0.0)
        inputView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext() as! UIImage
        UIGraphicsEndImageContext()
        let cellSnapshot : UIView = UIImageView(image: image)
        cellSnapshot.layer.masksToBounds = false
        cellSnapshot.layer.cornerRadius = 0.0
        cellSnapshot.layer.shadowOffset = CGSize(width: -5.0, height: 0.0)
        cellSnapshot.layer.shadowRadius = 5.0
        cellSnapshot.layer.shadowOpacity = 0.4
        return cellSnapshot
    }

}

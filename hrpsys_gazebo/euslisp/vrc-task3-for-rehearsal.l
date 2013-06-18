(progn
  (load "package://hrpsys_gazebo/euslisp/atlas-interface.l")
  (unless (and x::*display* (> x::*display* 0))
    (load "package://hrpsys_gazebo/euslisp/no-display"))
  (atlas-init :set-reset-pose nil :set-user-mode nil)
  (send *ri* :hand :rarm :wait-interpolation)
  (send *ri* :hand :larm :wait-interpolation)
  (unless (boundp '*completion-score*)
    (defparameter *completion_score* 0))
  )

;; overwrite
;; (defun hand-model2real (&key (arm :both) (wait t) (time 1000))
;;   (cond
;;    ((equal arm :both) (hand-model2real :arm :larm :wait wait) (hand-model2real :arm :rarm :wait wait))
;;    (t (set-real-hand-av (get-model-hand-av arm) arm time)
;;       (when wait (send *ri* :hand arm :wait-interpolation)))))

(defun score-callback-for-task3
  (msg)
  (print (send msg :completion_score))
  (print (defparameter *completion-score* (send msg :completion_score))))

(ros::subscribe "/vrc_score"
                atlas_msgs::vrcscore
                #'score-callback-for-task3)

(defun init-pose-for-hose ()
  (objects (list *atlas*))
  (send *atlas* :reset-manip-pose :base-down t)
  (send *atlas* :arms :move-end-pos #f(-100 0 0) :world :rotation-axis nil)
  ;;(send *atlas* :larm :angle-vector #f(30.0 90.0 0.0 -79.9998 15.0 0.0))
  (send *atlas* :hand :rarm :open-pose2)
  (progn (model2real) (hand-model2real :time 1000) (send *ri* :wait-interpolation))
  )

(defun reach-and-pickup-hose
  (&key (hose-grasp-x-pos 400)
	(hose-grasp-y-pos -650))
  (send *atlas* :reset-manip-pose :base-down t)
  ;;(send *atlas* :larm :angle-vector #f(30.0 90.0 0.0 -79.9998 15.0 0.0))
  (send *atlas* :rarm :inverse-kinematics
	(send (make-coords :pos (float-vector hose-grasp-x-pos -550 1300) :rpy (list 0 0 -pi/2)) :rotate pi/2 :y :world)
	:debug-view :no-message :thre 5 :stop 200
	:rotation-axis :z)
  (send *atlas* :head :neck-p :joint-angle 50)
  (send *atlas* :move-centroid-on-foot
	:both '(:rleg :lleg :rarm)
	:target-centroid-pos (send *atlas* :calc-target-centroid-pos :both '(:rleg :lleg)))
  (progn (model2real :time 2000) (hand-model2real :time 1000) (send *ri* :wait-interpolation))

  (send *atlas* :rarm :inverse-kinematics
	(send (make-coords :pos (float-vector hose-grasp-x-pos hose-grasp-y-pos 1300) :rpy (list 0 0 -pi/2)) :rotate pi/2 :y :world)
	:debug-view :no-message :thre 5 :stop 200
	:rotation-axis :z)
  (send *atlas* :head :neck-p :joint-angle 50)
  (send *atlas* :move-centroid-on-foot
	:both '(:rleg :lleg :rarm)
	:target-centroid-pos (send *atlas* :calc-target-centroid-pos :both '(:rleg :lleg)))
  (progn (model2real :time 1000) (hand-model2real :time 1000) (send *ri* :wait-interpolation))

  (send *atlas* :rarm :inverse-kinematics
	(send (make-coords :pos (float-vector hose-grasp-x-pos hose-grasp-y-pos 1100) :rpy (list 0 0 -pi/2)) :rotate pi/2 :y :world)
	:debug-view :no-message :thre 5 :stop 200 :rotation-axis :z)
  (send *atlas* :head :neck-p :joint-angle 50)
  (send *atlas* :move-centroid-on-foot
	:both '(:rleg :lleg :rarm)
	:target-centroid-pos (send *atlas* :calc-target-centroid-pos :both '(:rleg :lleg)))
  (progn (model2real :time 2000) (hand-model2real :time 1000) (send *ri* :wait-interpolation))

  (send *atlas* :hand :rarm :angle-vector #f(0.0 90.0 40.0 0.0 90.0 40.0 0.0 90.0 40.0 0.0 50.0 20.0))
  (set-hand-kp 1)
  (progn (model2real) (hand-model2real :time 1000) (send *ri* :wait-interpolation))
  (dotimes (i 50) (set-hand-kp (* (+ i 1) 1))(unix:usleep 200000))

  (send *atlas* :rarm :inverse-kinematics
	(send (make-coords :pos (float-vector hose-grasp-x-pos hose-grasp-y-pos 1250) :rpy (list 0 0 -pi/2)) :rotate pi/2 :y :world)
	:debug-view :no-message :thre 5 :stop 200 :rotation-axis :z)
  (send *atlas* :head :neck-p :joint-angle 50)
  (send *atlas* :move-centroid-on-foot
	:both '(:rleg :lleg :rarm)
	:target-centroid-pos (send *atlas* :calc-target-centroid-pos :both '(:rleg :lleg)))
  (progn (model2real :time 2000) (hand-model2real :time 1000) (send *ri* :wait-interpolation))
  )

(defun twist-torso ()
  (progn
    (send *atlas* :torso :waist-y :joint-angle -35)
    (progn (model2real :time 1000) (hand-model2real :time 1000) (send *ri* :wait-interpolation))
    (send *atlas* :torso :waist-y :joint-angle 35)
    (progn (model2real :time 5000) (hand-model2real :time 1000) (send *ri* :wait-interpolation))
    (send *atlas* :torso :waist-y :joint-angle 0)
    (progn (model2real :time 1000) (hand-model2real :time 1000) (send *ri* :wait-interpolation))
    ;; (send *atlas* :torso :waist-y :joint-angle 35)
    ;; (send *atlas* :rarm :inverse-kinematics
    ;; 	(send (make-coords :pos #f(500 200 1300) :rpy (list 0 0 -pi/2)) :rotate pi/2 :y :world)
    ;; 	:debug-view :no-message :thre 5 :stop 200 :rotation-axis nil)
    ;; (send *atlas* :move-centroid-on-foot
    ;; 	:both '(:rleg :lleg :rarm)
    ;; 	:target-centroid-pos (send *atlas* :calc-target-centroid-pos :both '(:rleg :lleg)))
    ;; (progn (model2real :time 7000) (hand-model2real :time 1000) (send *ri* :wait-interpolation))
    ))

(defun twist-torso2 ()
  (progn
    ;;(send *atlas* :torso :waist-y :joint-angle -35)
    ;;(progn (model2real :time 1000) (hand-model2real :time 1000) (send *ri* :wait-interpolation))
    (send *atlas* :torso :waist-y :joint-angle 35)
    (send *atlas* :move-centroid-on-foot
	  :both '(:rleg :lleg :rarm)
	  :target-centroid-pos (send *atlas* :calc-target-centroid-pos :both '(:rleg :lleg)))
    (progn (model2real :time 5000) (hand-model2real :time 1000) (send *ri* :wait-interpolation))
    (send *atlas* :torso :waist-y :joint-angle 0)
    (progn (model2real :time 5000) (hand-model2real :time 1000) (send *ri* :wait-interpolation))
    ;; (send *atlas* :torso :waist-y :joint-angle 35)
    ;; (send *atlas* :rarm :inverse-kinematics
    ;; 	(send (make-coords :pos #f(500 200 1300) :rpy (list 0 0 -pi/2)) :rotate pi/2 :y :world)
    ;; 	:debug-view :no-message :thre 5 :stop 200 :rotation-axis nil)
    ;; (send *atlas* :move-centroid-on-foot
    ;; 	:both '(:rleg :lleg :rarm)
    ;; 	:target-centroid-pos (send *atlas* :calc-target-centroid-pos :both '(:rleg :lleg)))
    ;; (progn (model2real :time 7000) (hand-model2real :time 1000) (send *ri* :wait-interpolation))
    ))


(defun grasp-hose-by-larm ()
  (send *atlas* :rarm :inverse-kinematics
  	(send (send (make-coords :pos #f(500 -80 1300) :rpy (list 0 0 -pi/2)) :rotate pi/2 :y :world) :rotate (deg2rad -30) :x)
  	:debug-view :no-message :thre 10 :stop 200 :rotation-axis :z)  
  (send *atlas* :larm :inverse-kinematics
  	(send (send (make-coords :pos #f(400 80 1400) :rpy (list 0 0 pi/2)) :rotate pi/2 :y :world) :rotate (deg2rad 30) :x)
  	:debug-view :no-message :thre 10 :stop 200 :rotation-axis :z) 
  (send *atlas* :move-centroid-on-foot
  	:both '(:rleg :lleg)
  	:target-centroid-pos (send *atlas* :calc-target-centroid-pos :both '(:rleg :lleg)))
  (progn (model2real) (hand-model2real :time 1000) (send *ri* :wait-interpolation))

  (send *atlas* :larm :inverse-kinematics
  	(send (send (make-coords :pos #f(500 80 1300) :rpy (list 0 0 pi/2)) :rotate pi/2 :y :world) :rotate (deg2rad 30) :x)
  	:debug-view :no-message :thre 10 :stop 200 :rotation-axis :z) 
  (send *atlas* :move-centroid-on-foot
  	:both '(:rleg :lleg)
  	:target-centroid-pos (send *atlas* :calc-target-centroid-pos :both '(:rleg :lleg)))
  (progn (model2real :time 1000) (hand-model2real :time 1000) (send *ri* :wait-interpolation))

  (send *atlas* :hand :larm :angle-vector #f(0.0 90.0 40.0 0.0 90.0 40.0 0.0 90.0 40.0 0.0 90.0 20.0))
  (progn (model2real) (hand-model2real :time 1000) (send *ri* :wait-interpolation))

  (send *atlas* :hand :larm :angle-vector #f(0.0 90.0 40.0 0.0 90.0 40.0 0.0 90.0 40.0 0.0 90.0 70.0))
  ;;(send *atlas* :hand :larm :grasp-pose)
  (progn (model2real) (hand-model2real :time 1000) (send *ri* :wait-interpolation))

  (send *atlas* :hand :rarm :open-pose2)
  (progn (model2real) (hand-model2real :time 1000) (send *ri* :wait-interpolation))

  (send *atlas* :rarm :inverse-kinematics
  	(send (send (make-coords :pos #f(500 -80 1400) :rpy (list 0 0 -pi/2)) :rotate pi/2 :y :world) :rotate (deg2rad -30) :x)
  	:debug-view :no-message :thre 10 :stop 200 :rotation-axis :z)
  (progn (model2real) (hand-model2real :time 1000) (send *ri* :wait-interpolation))

  (send *atlas* :rarm :inverse-kinematics
  	(send (send (make-coords :pos #f(500 -400 1400) :rpy (list 0 0 -pi/2)) :rotate pi/2 :y :world) :rotate (deg2rad -30) :x)
  	:debug-view :no-message :thre 10 :stop 200 :rotation-axis :z)
  (progn (model2real) (hand-model2real :time 1000) (send *ri* :wait-interpolation))
  )

(defun grasp-hose-by-rarm ()
  (send *atlas* :larm :inverse-kinematics
  	(send (send (make-coords :pos #f(500 80 1500) :rpy (list 0 0 pi/2)) :rotate pi/2 :y :world) :rotate (deg2rad 30) :x)
  	:debug-view :no-message :thre 10 :stop 200 :rotation-axis :z) 
  (send *atlas* :rarm :wrist-y :joint-angle -90)
  (send *atlas* :rarm :inverse-kinematics
  	(send (send (make-coords :pos #f(500 -400 1200) :rpy (list 0 0 pi/2)) :rotate pi/2 :y :world) :rotate (deg2rad 30) :x)
  	:debug-view :no-message :thre 10 :stop 200 :rotation-axis :z)
  (send *atlas* :head :neck-p :joint-angle 50)
  (progn (model2real) (hand-model2real :time 1000) (send *ri* :wait-interpolation))

  ;; (send *atlas* :rarm :inverse-kinematics
  ;;   	(send (send (make-coords :pos #f(500 -400 1100) :rpy (list 0 0 pi/2)) :rotate pi/2 :y :world) :rotate (deg2rad 30) :x)
  ;;   	:debug-view :no-message :thre 10 :stop 200 :rotation-axis :z)
  ;; (progn (model2real) (hand-model2real :time 1000) (send *ri* :wait-interpolation))
  (send *atlas* :rarm :inverse-kinematics
  	(send (send (make-coords :pos #f(500 -100 1200) :rpy (list 0 0 pi/2)) :rotate pi/2 :y :world) :rotate (deg2rad 30) :x)
  	:debug-view :no-message :thre 10 :stop 200 :rotation-axis :z)
  (send *atlas* :head :neck-p :joint-angle 50)
  (progn (model2real) (hand-model2real :time 1000) (send *ri* :wait-interpolation))

  (send *atlas* :larm :inverse-kinematics
  	(send (send (make-coords :pos #f(500 0 1300) :rpy (list 0 0 pi/2)) :rotate pi/2 :y :world) :rotate (deg2rad 30) :x)
  	:debug-view :no-message :thre 10 :stop 200 :rotation-axis :z) 
  (send *atlas* :head :neck-p :joint-angle 50)
  (progn (model2real) (hand-model2real :time 1000) (send *ri* :wait-interpolation))
  
  (send *atlas* :hand :rarm :angle-vector #f(0.0 90.0 40.0 0.0 90.0 40.0 0.0 90.0 40.0 0.0 50.0 20.0))
  (set-hand-kp 1)
  (progn (model2real) (hand-model2real :time 1000) (send *ri* :wait-interpolation))
  (dotimes (i 50) (set-hand-kp (* (+ i 1) 1))(unix:usleep 200000))

  (send *atlas* :hand :larm :open-pose2)
  (set-hand-kp 1)
  (progn (model2real) (hand-model2real :time 1000) (send *ri* :wait-interpolation))
  (dotimes (i 50) (set-hand-kp (* (+ i 1) 1))(unix:usleep 200000))

  (send *atlas* :larm :angle-vector #f(110.0 90.0 30.0 -79.9998 15.0 0.0))
  (send *atlas* :move-centroid-on-foot
  	:both '(:rleg :lleg)
  	:target-centroid-pos (send *atlas* :calc-target-centroid-pos :both '(:rleg :lleg)))
  (progn (model2real) (hand-model2real :time 1000) (send *ri* :wait-interpolation))

  (send *atlas* :rarm :inverse-kinematics
  	(send (send (make-coords :pos #f(500 -80 1300) :rpy (list 0 0 -pi/2)) :rotate pi/2 :y :world) :rotate (deg2rad -30) :x)
  	:debug-view :no-message :thre 10 :stop 200 :rotation-axis :z)  
  (send *atlas* :move-centroid-on-foot
  	:both '(:rleg :lleg)
  	:target-centroid-pos (send *atlas* :calc-target-centroid-pos :both '(:rleg :lleg)))
  (progn (model2real) (hand-model2real :time 1000) (send *ri* :wait-interpolation))
  )

(defun move-base-rot (ang)
  (let* ((prc (send *atlas* :copy-worldcoords))
	 (pav (send *atlas* :angle-vector))
	 (lc (mapcar #'(lambda (ll) (send *atlas* ll :end-coords :copy-worldcoords)) '(:rleg :lleg))))
    (send *atlas* :rotate (deg2rad ang) :z :world)
    (let ((ret
	   (mapcar #'(lambda (ll c)
		       (send *atlas* ll :inverse-kinematics c))
		   '(:rleg :lleg) lc)))
      (if (every #'identity ret)
	  (send *atlas* :angle-vector)
	(progn
	  (send *atlas* :newcoords prc)
	  (send *atlas* :angle-vector pav)
	  nil)
	)
      )))

(defun mate-hose-by-larm-0 ()
  (send *atlas* :reset-manip-pose :base-down t)
  (send *atlas* :rarm :angle-vector #f(-56.6679 67.8617 -23.1484 22.3583 -47.8993 28.1287))
  (send *atlas* :torso :waist-y :joint-angle 35)
  (move-base-rot 10)
  (send *atlas* :larm :inverse-kinematics
  	(send (send (make-coords :pos #f(300 400 1500) :rpy (list 0 0 -pi/2)) :rotate 0 :y :world) :rotate (deg2rad 30) :x)
  	:debug-view :no-message :thre 10 :stop 200 :rotation-axis nil)
  (send *atlas* :rarm :angle-vector #f(-118.773 102.047 -37.5247 79.9989 39.1444 2.12699))
  (send *atlas* :move-centroid-on-foot
  	:both '(:rleg :lleg)
  	:target-centroid-pos (send *atlas* :calc-target-centroid-pos :both '(:rleg :lleg)))
  (progn (model2real :time 2000) (hand-model2real :time 1000) (send *ri* :wait-interpolation))

  (send *atlas* :larm :inverse-kinematics
  	(send (send (make-coords :pos #f(300 400 1100) :rpy (list 0 0 -pi/2)) :rotate 0 :y :world) :rotate (deg2rad 30) :x)
  	:debug-view :no-message :thre 10 :stop 200 :rotation-axis nil)
  (send *atlas* :move-centroid-on-foot
  	:both '(:rleg :lleg)
  	:target-centroid-pos (send *atlas* :calc-target-centroid-pos :both '(:rleg :lleg)))
  (progn (model2real :time 2000) (hand-model2real :time 1000) (send *ri* :wait-interpolation))

  ;; (send *atlas* :hand :larm :angle-vector #f(0.0 90.0 00.0 0.0 90.0 00.0 0.0 90.0 00.0 0.0 90.0 70.0))
  ;; (progn (model2real :time 2000) (hand-model2real :time 1000) (send *ri* :wait-interpolation))
  ;; (send *atlas* :hand :larm :angle-vector #f(0.0 90.0 70.0 0.0 90.0 70.0 0.0 90.0 70.0 0.0 90.0 70.0))
  ;; (progn (model2real :time 2000) (hand-model2real :time 1000) (send *ri* :wait-interpolation))

  (send *atlas* :reset-manip-pose :base-down t)
  (send *atlas* :rarm :angle-vector #f(-56.6679 67.8617 -23.1484 22.3583 -47.8993 28.1287))
  (send *atlas* :torso :waist-y :joint-angle 35)
  (move-base-rot 15)
  (with-assoc-move-target
   (mt :move-target (send *atlas* :get :larm-hand-coords-for-hose)
       :parent-link (send *atlas* :larm :end-coords :parent))
   (let* ((ll (send *atlas* :link-list (send (car mt) :parent)))
	  (wei (fill (instantiate float-vector (send *atlas* :calc-target-joint-dimension ll)) 1.0)))
     (dolist (idx (mapcar #'(lambda (j) (position j (send-all (send *atlas* :link-list (send *atlas* :larm :end-coords :parent)) :joint))) (send *atlas* :torso :joint-list)))
       (setf (elt wei idx) 0.05))
     (send *atlas* :inverse-kinematics
	   (send (make-coords :pos #f(200 600 1200) :rpy (list 0 0 -pi/2)) :rotate (deg2rad 0) :z :world)
	   :link-list ll
	   :move-target (car mt)
	   :weight wei
	   :debug-view :no-message :thre 10 :stop 200 :rotation-axis :z)))
  (send *atlas* :rarm :wrist-y :joint-angle -90)
  (send *atlas* :move-centroid-on-foot
	:both '(:rleg :lleg :larm)
	:target-centroid-pos (send *atlas* :calc-target-centroid-pos :both '(:rleg :lleg))
	:centroid-thre 40)
  (progn (model2real :time 2000) (hand-model2real :time 1000) (send *ri* :wait-interpolation))

  (setq *ikc* (send (send *atlas* :get :larm-hand-coords-for-hose) :copy-worldcoords))
  ;;(move-hose-end-from-ikc (float-vector 0 0 0) 0)
  ;;(move-hose-end-from-ikc (float-vector -100 70 300) 0)
  (move-hose-end-from-ikc (float-vector 0 0 0) 0)
  )

(defun test-ik1
  (target-coords &key (rotation-axis :z) (init-pose nil) (thre 10))
  (let ((pav (send *atlas* :angle-vector))
	(prc (send *atlas* :copy-worldcoords))
	(ret t))

    (when init-pose
      (send *atlas* :reset-manip-pose :base-down t)
      (send *atlas* :rarm :angle-vector #f(-56.6679 67.8617 -23.1484 22.3583 -47.8993 28.1287))
      (send *atlas* :torso :waist-y :joint-angle 35)
      (move-base-rot 15))

    (with-assoc-move-target
     (mt :move-target (send *atlas* :get :larm-hand-coords-for-hose)
	 :parent-link (send *atlas* :larm :end-coords :parent))
     (let* ((ll (send *atlas* :link-list (send (car mt) :parent)))
	    (wei (fill (instantiate float-vector (send *atlas* :calc-target-joint-dimension ll)) 1.0)))
       (dolist (idx (mapcar #'(lambda (j) (position j (send-all (send *atlas* :link-list (send *atlas* :larm :end-coords :parent)) :joint))) (send *atlas* :torso :joint-list)))
	 (setf (elt wei idx) 0.05))
       (setq ret
	     (and ret
		  (send *atlas* :inverse-kinematics
			target-coords
			:link-list ll
			:move-target (car mt)
			:weight wei
			:debug-view :no-message :thre thre :stop 200 :rotation-axis rotation-axis)))))
    (setq ret
	  (and ret
	       (send *atlas* :move-centroid-on-foot
		     :both '(:rleg :lleg :larm)
		     :target-centroid-pos (send *atlas* :calc-target-centroid-pos :both '(:rleg :lleg))
		     :centroid-thre 40)))
    (send *atlas* :head :neck-p :joint-angle 50)
    (unless ret
      (send *atlas* :angle-vector pav)
      (send *atlas* :newcoords prc))
    ))

;; (move-hose-end-from-ikc (float-vector 0 0 0) 0)
;; (progn (move-hose-end-from-ikc (float-vector 0 0 0) 0) (unix:sleep 2) (print (send (send *atlas* :force-sensor :lhsensor) :rotate-vector (send *ri* :force-vector :larm))) (print (send (send *atlas* :force-sensor :lhsensor) :rotate-vector (send *ri* :moment-vector :larm))) (unix:sleep 2) (snapshot-image :rarm) (snapshot-image :head) (progn (dotimes (i 10) (ros::spin-once)) *completion-score*))
(defun move-hose-end-from-ikc
  (&optional (dif-pos (float-vector 0 0 0)) (zang 0) (rotation-axis t))
  (test-ik1 (send (send (send *ikc* :copy-worldcoords) :translate dif-pos :world) :rotate (deg2rad zang) :z :world)
	    :init-pose t :rotation-axis rotation-axis :thre 2.5)
  (send *atlas* :rarm :wrist-y :joint-angle -30)
  (progn (model2real :time 1000) (hand-model2real :time 1000) (send *ri* :wait-interpolation))
  )

(defun release-hose-end ()
  (setq *ikc* (send (send *atlas* :get :larm-hand-coords-for-hose) :copy-worldcoords))
  (let ((ret t)
	(ang 10))
    (while ret
      (setq ret (test-ik1 (send (send *ikc* :copy-worldcoords) :rotate (deg2rad ang) :z)
			  :init-pose t :rotation-axis t :thre 2.5))
      (setq ang (+ ang 10))
      (progn (model2real :time 2000) (hand-model2real :time 1000) (send *ri* :wait-interpolation))))
  (send *atlas* :hand :larm :open-pose2)
  (progn (model2real :time 1000) (hand-model2real :time 1000) (send *ri* :wait-interpolation))
  (move-hose-end-from-ikc (float-vector -100 0 -100) 0 :z)
  (send *atlas* :hand :larm :angle-vector #f(0.0 90.0 40.0 0.0 90.0 40.0 0.0 90.0 40.0 0.0 90.0 70.0))
  (progn (model2real :time 1000) (hand-model2real :time 1000) (send *ri* :wait-interpolation))
  (snapshot-image :all)
  (move-hose-end-from-ikc (float-vector -100 -100 -50) 0 nil)
  (snapshot-image :all)
  (move-hose-end-from-ikc (float-vector -200 -200 -50) 0 nil)
  (snapshot-image :all)
  (send *atlas* :rarm :angle-vector #f(-135.0 67.8617 -23.1484 70.0 0.0 -30.0))
  (send *atlas* :larm :angle-vector #f(135.0 67.8617 23.1484 -70.0 0.0 -30.0))
  (send *atlas* :move-centroid-on-foot
	:both '(:rleg :lleg)
	:target-centroid-pos (send *atlas* :calc-target-centroid-pos :both '(:rleg :lleg))
	:centroid-thre 40)
  (progn (model2real :time 5000) (hand-model2real :time 1000) (send *ri* :wait-interpolation))
  (snapshot-image :all)
  (send *atlas* :reset-manip-pose :base-down t)
  (send *atlas* :rarm :angle-vector #f(-135.0 67.8617 -23.1484 70.0 0.0 -30.0))
  (send *atlas* :larm :angle-vector #f(135.0 67.8617 23.1484 -70.0 0.0 -30.0))
  (send *atlas* :head :neck-p :joint-angle 50)
  (send *atlas* :move-centroid-on-foot
	:both '(:rleg :lleg)
	:target-centroid-pos (send *atlas* :calc-target-centroid-pos :both '(:rleg :lleg))
	:centroid-thre 40)
  (progn (model2real :time 5000) (hand-model2real :time 1000) (send *ri* :wait-interpolation))
  (send *atlas* :hand :larm :open-pose2)
  (progn (model2real :time 1000) (hand-model2real :time 1000) (send *ri* :wait-interpolation))
  )

(defun go-pos2 ()
  (send *ri* :start-auto-balancer)
  (send *ri* :start-st)
  (send *ri* :go-pos -0.2 0 0)
  )

;; (progn (prepare-for-rotate-hose #f(500 100 1400)) (unix:sleep 1) (snapshot-image :larm))
(defun prepare-for-rotate-hose
  (&optional (pos #f(500 100 1300)) (zang 0) (tm 5000) (rotation-axis :z))
  (test-ik1 
   (send (make-coords :pos pos :rpy (list 0 0 pi/2)) :rotate (deg2rad zang) :z :world)
   :rotation-axis rotation-axis)
  (progn (model2real :time tm) (hand-model2real :time 1000) (send *ri* :wait-interpolation))
  )

(defun rotate-hose ()
  (setq *ikc* (send (send *atlas* :get :larm-hand-coords-for-hose) :copy-worldcoords))
  (let ()
    (send *atlas* :hand :larm :open-pose2)
    (progn (model2real :time 2000) (hand-model2real :time 2000) (send *ri* :wait-interpolation))
    (test-ik1 (send (send *ikc* :copy-worldcoords) :translate (float-vector 0 0 40) :world) :init-pose t :rotation-axis t)
    (progn (model2real :time 1000) (hand-model2real :time 1000) (send *ri* :wait-interpolation))
    (do ((ang 10 (+ ang 30))) ((< 50 ang))
      (test-ik1 (send (send (send *ikc* :copy-worldcoords) :translate (float-vector 0 0 40) :world) :rotate (deg2rad ang) :z) :init-pose t :rotation-axis t)
      (progn (model2real :time 1000) (hand-model2real :time 1000) (send *ri* :wait-interpolation)))
    (test-ik1 (send (send (send *ikc* :copy-worldcoords) :translate (float-vector 0 -50 -30) :world) :rotate (deg2rad 50) :z) :init-pose t :rotation-axis t)
    (progn (model2real :time 1000) (hand-model2real :time 1000) (send *ri* :wait-interpolation))
    (send *atlas* :hand :larm :angle-vector #f(0.0 90.0 40.0 0.0 90.0 40.0 0.0 90.0 40.0 0.0 90.0 70.0))
    (progn (model2real :time 2000) (hand-model2real :time 2000) (send *ri* :wait-interpolation))
    (do ((ang 50 (+ ang -10))) ((< ang -30))
      (test-ik1 (send (send (send *ikc* :copy-worldcoords) :translate (float-vector 0 -50 -30) :world) :rotate (deg2rad ang) :z) :init-pose t :rotation-axis t)
      (progn (model2real :time 1000) (hand-model2real :time 1000) (send *ri* :wait-interpolation)))
    )
  )

(defun mate-hose-by-larm-1 ()
 (send *atlas* :hand :larm :open-pose2)
 (progn (model2real :time 1000) (hand-model2real :time 1000) (send *ri* :wait-interpolation))
 (setq *ikc* (send (send *atlas* :get :larm-hand-coords-for-hose) :copy-worldcoords))
 (let ()
   (send *atlas* :hand :larm :open-pose2)
   (progn (model2real :time 2000) (hand-model2real :time 2000) (send *ri* :wait-interpolation))
   (test-ik1 (send (send *ikc* :copy-worldcoords) :translate (float-vector 0 0 40) :world) :init-pose t :rotation-axis t)
   (progn (model2real :time 1000) (hand-model2real :time 1000) (send *ri* :wait-interpolation))
   (do ((ang 10 (+ ang 30))) ((< 50 ang))
     (test-ik1 (send (send (send *ikc* :copy-worldcoords) :translate (float-vector 0 0 40) :world) :rotate (deg2rad ang) :z) :init-pose t :rotation-axis t)
     (progn (model2real :time 1000) (hand-model2real :time 1000) (send *ri* :wait-interpolation)))
   (test-ik1 (send (send (send *ikc* :copy-worldcoords) :translate (float-vector 0 -50 -30) :world) :rotate (deg2rad 50) :z) :init-pose t :rotation-axis t)
   (progn (model2real :time 1000) (hand-model2real :time 1000) (send *ri* :wait-interpolation))
   (send *atlas* :hand :larm :angle-vector #f(0.0 90.0 40.0 0.0 90.0 40.0 0.0 90.0 40.0 0.0 90.0 70.0))
   (progn (model2real :time 2000) (hand-model2real :time 2000) (send *ri* :wait-interpolation))
   (do ((ang 50 (+ ang -10))) ((< ang -30))
     (test-ik1 (send (send (send *ikc* :copy-worldcoords) :translate (float-vector 0 -50 -30) :world) :rotate (deg2rad ang) :z) :init-pose t :rotation-axis t)
     (progn (model2real :time 1000) (hand-model2real :time 1000) (send *ri* :wait-interpolation)))
   )

 (let ((ang0 -30) (ang1 15))
   (send *atlas* :hand :larm :open-pose2)
   (progn (model2real :time 2000) (hand-model2real :time 1000) (send *ri* :wait-interpolation))
   (test-ik1 (send (send *ikc* :copy-worldcoords) :translate (float-vector 0 0 -30) :world) :init-pose t :rotation-axis t)
   (progn (model2real :time 1000) (hand-model2real :time 1000) (send *ri* :wait-interpolation))
   (test-ik1 (send (send (send *ikc* :copy-worldcoords) :translate (float-vector 0 0 -30) :world) :rotate (deg2rad ang0) :z) :init-pose t :rotation-axis t)
    (progn (model2real :time 1000) (hand-model2real :time 1000) (send *ri* :wait-interpolation))
(test-ik1 (send (send (send *ikc* :copy-worldcoords) :translate (float-vector 0 0 0) :world) :rotate (deg2rad ang0) :z) :init-pose t :rotation-axis t)
    (progn (model2real :time 1000) (hand-model2real :time 1000) (send *ri* :wait-interpolation))
    (send *atlas* :hand :larm :angle-vector #f(0.0 90.0 40.0 0.0 90.0 40.0 0.0 90.0 40.0 0.0 90.0 70.0))
    (progn (model2real :time 2000) (hand-model2real :time 1000) (send *ri* :wait-interpolation))
    (test-ik1 (send (send *ikc* :copy-worldcoords) :rotate (deg2rad ang1) :z) :init-pose t :rotation-axis t)
    (progn (model2real :time 2000) (hand-model2real :time 1000) (send *ri* :wait-interpolation))
    )


  (send *atlas* :reset-manip-pose :base-down t)
  (send *atlas* :rarm :move-end-pos #f(0 100 0) :world :debug-view :no-message :rotation-axis :z)
  (send *atlas* :larm :move-end-pos #f(0 -100 0) :world :debug-view :no-message :rotation-axis :z)
  (send *atlas* :head :neck-p :joint-angle 50)
  (send *atlas* :move-centroid-on-foot
	:both '(:rleg :lleg)
	:target-centroid-pos (send *atlas* :calc-target-centroid-pos :both '(:rleg :lleg))
	:centroid-thre 40)

(dolist (vv (list #f(0 0 -70) #f(0 50 0) #f(0 0 70) #f(0 -50 0)))
  (send *atlas* :rarm :move-end-pos vv :world :debug-view :no-message :rotation-axis :z)
  (progn (model2real :time 2000) (hand-model2real :time 2000) (send *ri* :wait-interpolation)))
(progn
(send *atlas* :rarm :move-end-pos #f(0 30 0) :world :debug-view :no-message :rotation-axis :z)
(send *atlas* :larm :move-end-pos #f(0 -30 0) :world :debug-view :no-message :rotation-axis :z)
(send *atlas* :head :neck-p :joint-angle 50)
(send *atlas* :move-centroid-on-foot
	:both '(:rleg :lleg :rarm :larm)
	:target-centroid-pos (send *atlas* :calc-target-centroid-pos :both '(:rleg :lleg))
	:centroid-thre 40))

(let ((ac (rot-handle 15)))
  (send *atlas* :rarm :inverse-kinematics (car ac) :debug-view :no-message :rotation-axis :z)
  (send *atlas* :larm :inverse-kinematics (cadr ac) :debug-view :no-message :rotation-axis :z)
  (send *atlas* :head :neck-p :joint-angle 50)
  (send *atlas* :move-centroid-on-foot
	:both '(:rleg :lleg :rarm :larm)
	:target-centroid-pos (send *atlas* :calc-target-centroid-pos :both '(:rleg :lleg))
	:centroid-thre 40))

(dotimes (i 3) (let ((ac (rot-handle 10)))
  (send *atlas* :rarm :inverse-kinematics (car ac) :debug-view :no-message :rotation-axis :z)
  (send *atlas* :larm :inverse-kinematics (cadr ac) :debug-view :no-message :rotation-axis :z)
  (send *atlas* :head :neck-p :joint-angle 50)
  (send *atlas* :move-centroid-on-foot
	:both '(:rleg :lleg :rarm :larm)
	:target-centroid-pos (send *atlas* :calc-target-centroid-pos :both '(:rleg :lleg))
	:centroid-thre 40)
  (progn (model2real :time 2000) (hand-model2real :time 2000) (send *ri* :wait-interpolation))
  ))
;;


  (with-assoc-move-target
   (mt :move-target (send (send (send *atlas* :larm :end-coords :copy-worldcoords) :rotate (deg2rad -30) :x) :translate (float-vector 0 80 100))
       :parent-link (send *atlas* :larm :end-coords :parent))
   (send *atlas* :inverse-kinematics
	 (send (send (car mt) :copy-worldcoords) :translate (float-vector 0 0 30))
	 :link-list (send *atlas* :link-list (send (car mt) :parent))
	 :move-target (car mt)
	 :debug-view :no-message :thre 10 :stop 200 :rotation-axis :z))
  (send *atlas* :move-centroid-on-foot
  	:both '(:rleg :lleg :larm)
  	:target-centroid-pos (send *atlas* :calc-target-centroid-pos :both '(:rleg :lleg))
	:centroid-thre 40)
  (progn (model2real :time 2000) (hand-model2real :time 1000) (send *ri* :wait-interpolation))
  )

(defun rot-handle (ang)
  (let* ((arms '(:rarm :larm))
	 (ac (mapcar #'(lambda (a) (make-cascoords :coords (send *atlas* a :end-coords :copy-worldcoords))) arms))
	 (cen-c (make-cascoords :pos (send (apply #'midcoords 0.5 ac) :worldpos))))
    (send cen-c :assoc (car ac))
    (send cen-c :assoc (cadr ac))
    (send cen-c :rotate (deg2rad ang) :x)
    (print ac)
    ))

(defun setup-hand-coords-for-hose ()
  (unless (send *atlas* :get :larm-hand-coords-for-hose)
    (let ((lc (make-cascoords
	     :coords (send (send (send *atlas* :larm :end-coords :copy-worldcoords) :rotate (deg2rad -40) :x) :translate (float-vector 60 80 120))
	     :name :larm-hand-coords-for-hose)))
    (send (send *atlas* :larm :end-coords :parent) :assoc lc)
    (send *atlas* :put :larm-hand-coords-for-hose lc)
    )))

(defun do-all-for-hose
  ()
  (send *ri* :teleport-to (make-coords :pos #f(-2700 -4100 1000)))
  (progn (real2model) (model2real :wait t :time 10) (set-user) (set-kp 4000))
  (unix:sleep 10)
  (setup-hand-coords-for-hose)
  (init-pose-for-hose)
  (unix:sleep 2)
  (reach-and-pickup-hose)
  (unix:sleep 2)
  (twist-torso)
  (unix:sleep 2)
  (grasp-hose-by-larm)
  (mate-hose-by-larm-0)
  )
;;(do-all-for-hose)
 
#|


  (with-assoc-move-target
   (mt :move-target (send (send (send *atlas* :rarm :end-coords :copy-worldcoords) :rotate (deg2rad 30) :x) :translate (float-vector 60 -80 100))
       :parent-link (send *atlas* :rarm :end-coords :parent))
     (send *atlas* :rarm :inverse-kinematics
           (send (send (send (send *atlas* :larm :end-coords :copy-worldcoords) :rotate (deg2rad -30) :x) :translate (float-vector 60 80 100)) :translate (float-vector 0 0 0))
	   :move-target (car mt)
	   :debug-view :no-message :thre 10 :stop 200 :rotation-axis :z))


(send *atlas* :hand :larm :grasp-pose)
(send *ri* :start-impedance
      :larm :force-gain #f(0 0 0)
      :moment-gain #f(0 0 1)
      ;;:m-r 5 :d-r 100 :k-r 200
      :m-r 5 :d-r 50 :k-r 0.5)


;;
(send *atlas* :hand :larm :reset-pose)
(progn (model2real) (hand-model2real :time 1000) (send *ri* :wait-interpolation))

(send *atlas* :fix-leg-to-coords (make-coords))
(send *atlas* :larm :inverse-kinematics
  	(send (send (make-coords :pos #f(450 200 1050) :rpy (list 0 0 pi/2)) :rotate pi/2 :y :world) :rotate (deg2rad 0) :x)
  	:debug-view :no-message :thre 10 :stop 200 :rotation-axis :z)
(progn (model2real) (hand-model2real :time 1000) (send *ri* :wait-interpolation))

(send *atlas* :hand :larm :angle-vector #f(0.0 30.0 0.0 0.0 30.0 0.0 0.0 30.0 0.0 0.0 90.0 0.0))
(progn (model2real) (hand-model2real :time 1000) (send *ri* :wait-interpolation))

(send *atlas* :move-centroid-on-foot
  	:both '(:rleg :lleg :larm)
  	:target-centroid-pos (send *atlas* :calc-target-centroid-pos :both '(:rleg :lleg) 0.2))
(progn (model2real :time 1500) (hand-model2real :time 1000) (send *ri* :wait-interpolation))

(send *atlas* :lleg :move-end-pos #f(0 0 20) :world)
(progn (model2real :time 700) (hand-model2real :time 1000) (send *ri* :wait-interpolation))
(send *atlas* :lleg :move-end-pos #f(0 100 0) :world)
(progn (model2real :time 700) (hand-model2real :time 1000) (send *ri* :wait-interpolation))
(send *atlas* :lleg :move-end-pos #f(0 0 -20) :world)
(progn (model2real :time 700) (hand-model2real :time 1000) (send *ri* :wait-interpolation))

(send *atlas* :move-centroid-on-foot
  	:both '(:rleg :lleg :larm)
  	:target-centroid-pos (send *atlas* :calc-target-centroid-pos :both '(:rleg :lleg) ))
(progn (model2real) (hand-model2real :time 1000) (send *ri* :wait-interpolation))

(send *atlas* :larm :inverse-kinematics
  	(send (send (make-coords :pos #f(450 300 1050) :rpy (list 0 0 pi/2)) :rotate pi/2 :y :world) :rotate (deg2rad 0) :x)
  	:debug-view :no-message :thre 10 :stop 200 :rotation-axis :z)
(send *atlas* :torso :waist-r :joint-angle 0)
(progn (model2real) (hand-model2real :time 1000) (send *ri* :wait-interpolation))

(send *atlas* :move-centroid-on-foot
  	:both '(:rleg :lleg :larm)
  	:target-centroid-pos (send *atlas* :calc-target-centroid-pos :both '(:rleg :lleg) 0.8))
(progn (model2real :time 1500) (hand-model2real :time 1000) (send *ri* :wait-interpolation))

(send *atlas* :rleg :move-end-pos #f(0 0 20) :world)
(progn (model2real :time 700) (hand-model2real :time 1000) (send *ri* :wait-interpolation))
(send *atlas* :rleg :move-end-pos #f(0 100 0) :world)
(progn (model2real :time 700) (hand-model2real :time 1000) (send *ri* :wait-interpolation))
(send *atlas* :rleg :move-end-pos #f(0 0 -20) :world)
(progn (model2real :time 700) (hand-model2real :time 1000) (send *ri* :wait-interpolation))
(send *atlas* :move-centroid-on-foot
  	:both '(:rleg :lleg :larm)
  	:target-centroid-pos (send *atlas* :calc-target-centroid-pos :both '(:rleg :lleg)))
(progn (model2real :time 1500) (hand-model2real :time 1000) (send *ri* :wait-interpolation))



;;

(send *atlas* :torso :waist-y :joint-angle 10)
(send *atlas* :move-centroid-on-foot
  	:both '(:rleg :lleg)
  	:target-centroid-pos (send *atlas* :calc-target-centroid-pos :both '(:rleg :lleg)))
(progn (model2real) (hand-model2real :time 1000) (send *ri* :wait-interpolation))
)

(send *atlas* :rarm :inverse-kinematics
  	(send (send (make-coords :pos #f(500 -400 1300) :rpy (list 0 0 -pi/2)) :rotate pi/2 :y :world) :rotate (deg2rad -30) :x)
  	:debug-view :no-message :thre 10 :stop 200 :rotation-axis :z)  

(send *atlas* :rarm :inverse-kinematics
  	(send (send (make-coords :pos #f(500 -400 1300) :rpy (list 0 0 pi/2)) :rotate pi/2 :y :world) :rotate (deg2rad 0) :x)
  	:debug-view :no-message :thre 10 :stop 200 :rotation-axis :z)

(send *ri* :set-auto-balancer-param
       :default-zmp-offsets (list (float-vector 30 20 0) (float-vector 30 -20 0)))
(send *ri* :set-gait-generator-param
         :default-double-support-ratio 0.5
         :default-step-time 1.0
         :default-step-height 0.05
         ;;:stride-parameter #f(0.25 0.05 10)
	 :stride-parameter #f(0.25 0.05 30))
(send *ri* :set-st-param
         :k-tpcc-p #f(1.5 1.5)
         :k-tpcc-x #f(5 5)
	 :k-brot-p #f(5 5)
         :k-brot-tc #f(0.1 0.1))
(progn (send *ri* :start-st) (send *ri* :go-pos -0.1 0 0) (send *ri* :stop-st))

;; new


(send *atlas* :torso :waist-y :joint-angle 35)
(send *atlas* :rarm :inverse-kinematics
      (send (make-coords :pos #f(400 -400 1300) :rpy (list 0 0 -pi/2)) :rotate pi/2 :y :world)
      :debug-view :no-message :thre 5 :stop 200 :rotation-axis :z)

(send *atlas* :rarm :inverse-kinematics
      (send (make-coords :pos #f(500 200 1300) :rpy (list 0 0 -pi/2)) :rotate pi/2 :y :world)
      :debug-view :no-message :thre 5 :stop 200 :rotation-axis nil)
(send *atlas* :move-centroid-on-foot
	 :both '(:rleg :lleg :rarm)
	 :target-centroid-pos (send *atlas* :calc-target-centroid-pos :both '(:rleg :lleg)))
p
(send *atlas* :rarm :move-end-pos #f(0 0 -100) :world :debug-view :no-message :thre 5)
(progn (send *atlas* :torso :waist-y :joint-angle -35) (progn (model2real :time 5000) (hand-model2real :time 1000) (send *ri* :wait-interpolation)) (send *atlas* :torso :waist-y :joint-angle 35) (progn (model2real :time 5000) (hand-model2real :time 1000) (send *ri* :wait-interpolation)))

(send *atlas* :hand :larm :open-pose2)
(send *atlas* :larm :inverse-kinematics
      (send (make-coords :pos #f(350 450 1100) :rpy (list 0 0 pi/2)) :rotate pi/2 :y :world)
      :debug-view :no-message :thre 5 :stop 200 :rotation-axis :z)
(send *atlas* :move-centroid-on-foot
	 :both '(:rleg :lleg :rarm)
	 :target-centroid-pos (send *atlas* :calc-target-centroid-pos :both '(:rleg :lleg)))

(send *atlas* :hand :larm :open-pose2)
(send *atlas* :larm :inverse-kinematics
      (send (make-coords :pos #f(500 450 1070) :rpy (list 0 0 pi/2)) :rotate pi/2 :y :world)
      :debug-view :no-message :thre 5 :stop 200 :rotation-axis :z)
(send *atlas* :move-centroid-on-foot
	 :both '(:rleg :lleg :rarm)
	 :target-centroid-pos (send *atlas* :calc-target-centroid-pos :both '(:rleg :lleg)))

|#
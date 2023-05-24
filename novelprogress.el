(global-set-key (kbd "s-#") #'my/ShowProgress_or_Characters)

(defvar Ziel)
(defvar Tagesziel)
(setq OverallGoal 550000)
(setq DailyGoal 6000)         ;; 6000 characters für two pages per day, if it is urgent, I can set it to 3 pages

(defvar NumberOfChars_INT)
(defvar NumberOfChars_STR)
(defvar Pages_STR)
(defvar Percent_INT)
(defvar Percent_STR)
(defvar Percent_CurrentPage_INT)
(defvar Percent_CurrentPage_STR)
(defvar NumberOfChars_Scene_INT)
(defvar Pages_Scene_STR)
(defvar NumberOfChars_Chapter_INT)
(defvar Pages_Chapter_STR)
(defvar StartingPoint)
(defvar Endpoint)
(defvar Status_before_STR)
(defvar Status_before_INT)
(defvar New_Today_STR)
(defvar New_Today_INT)
(defvar New_Today_Percent)
(defvar New_Today_Pages_INT)
(defvar New_Today_Pages_STR)
(defvar DailyGoal_Pages_INT)
(defvar DailyGoal_Pages_STR)
(defvar Bar_Done_Today)
(defvar Bar_Still_To_Do)
(defvar Bar_Color)

(defun my/ShowProgress_or_Characters ()
  (interactive)
   (setq NumberOfChars_INT (string-width (buffer-string)))
   (setq Pages_STR (number-to-string (/ NumberOfChars_INT 3000)))
   (setq NumberOfChars_STR (group-number NumberOfChars_INT))
   (setq Percent_INT (/ NumberOfChars_INT (/ OverallGoal 100)))
   (setq Percent_STR (number-to-string Percent_INT))
   (setq Percent_CurrentPage_INT (/ (- NumberOfChars_INT (* (/ NumberOfChars_INT 3000) 3000)) 30))
   (setq Percent_CurrentPage_STR (number-to-string Percent_CurrentPage_INT))

   ;; *************** Are we in the novel buffer? Then also count the length of the current scene and compare the progress with yesterday ***************
   (if (string-match "Manuskript" (buffer-name))
     (progn
     (save-excursion
       (outline-previous-visible-heading 1)
       (setq StartingPoint (point))
       (outline-next-visible-heading 1)
       (setq Endpoint (point)))
       (setq NumberOfChars_Scene_INT (string-width (buffer-substring-no-properties StartingPoint Endpoint)))
       (setq Pages_Scene_STR (number-to-string (/ NumberOfChars_Scene_INT 3000)))

     (setq Endpoint nil) ;; Delete Endpoint, so I find out whether counting starts from last chapter
     (save-excursion
       (outline-up-heading 1)
       (setq StartingPoint (point))
       ;; condition-case, because outline-forward-same-level will throw an error if no more header is following
       (condition-case nil (progn (outline-forward-same-level 1) (setq Endpoint (point))) (error (setq Endpoint (point-max))))
       ;; if Endpoint doesn’t contain a number because forward-same-level isn’t possible, count until end of buffer
       ) ;; if no number because it is the last chapter
     (setq NumberOfChars_Chapter_INT (string-width (buffer-substring-no-properties StartingPoint Endpoint)))
     (setq Pages_Chapter_STR (number-to-string (/ NumberOfChars_Chapter_INT 3000)))

     ;; When loaded the first time on this day, count the number of characters and save them in Status_before.txt
     ;; also append to file Novel_Status.txt, with date of the novel’s file
     ;; Afterwards always compare with current state of novel progress
     (setq Status_before_STR (my/read-file "/home/titus/Writer/Org/Status_before.txt"))
     (setq Status_before_INT (string-to-number Status_before_STR))
     (setq New_Today_INT (- NumberOfChars_INT Status_before_INT))
     (setq New_Today_STR (number-to-string New_Today_INT))
     (setq New_Today_Percent (/ New_Today_INT (/ DailyGoal 100)))
     (if (> New_Today_Percent 100) (setq New_Today_Percent 100))      ;; if more than 100 % of daily goal
     (if (< New_Today_INT 0) (setq New_Today_Percent 0))              ;; if less text then on the day before because of deleting/editing parts of it
     (setq New_Today_Number_of_Blocks (round (/ New_Today_Percent 10)))
     (setq Bar_Done_Today (make-string New_Today_Number_of_Blocks ?≡))
     (setq Bar_Still_To_Do (make-string (- 10 New_Today_Number_of_Blocks) ?=))
     (setq New_Today_Pages_INT (/ New_Today_INT 3000))
     (setq New_Today_Pages_STR (number-to-string New_Today_Pages_INT))
     (setq DailyGoal_Pages_INT (/ DailyGoal 3000))
     (setq DailyGoal_Pages_STR (number-to-string DailyGoal_Pages_INT))
     (setq Bar_Color "Gray81")
     (cl-case New_Today_Number_of_Blocks
       (1 (setq Bar_Color "NavajoWhite"))
       (2 (setq Bar_Color "LightSlateGray"))
       (3 (setq Bar_Color "MidnightBlue"))
       (4 (setq Bar_Color "CornflowerBlue"))
       (5 (setq Bar_Color "DodgerBlue"))
       (6 (setq Bar_Color "DeepSkyBlue"))
       (7 (setq Bar_Color "DarkTurquoise"))
       (8 (setq Bar_Color "MediumAquamarine"))
       (9 (setq Bar_Color "MediumSeaGreen"))
       (10 (setq Bar_Color "LimeGreen")))
     (if (> New_Today_Pages_INT DailyGoal_Pages_INT) (setq Bar_Color "gold"))
     (if (> New_Today_Pages_INT (+ DailyGoal_Pages_INT 1)) (setq Bar_Color "yellow"))
     (if (> New_Today_Pages_INT (+ DailyGoal_Pages_INT 2)) (setq Bar_Color "DarkGoldenrod1"))
     (message (concat NumberOfChars_STR " Characters, " Pages_STR " Pages, equals " Percent_STR " Percent" (propertize (concat " [New today: " Bar_Done_Today Bar_Still_To_Do " " New_Today_Pages_STR "/" DailyGoal_Pages_STR "] ") 'face `(:foreground ,Bar_Color)) "Current Page " Percent_CurrentPage_STR " Percent, Scene " Pages_Scene_STR " Pages, Chapter " Pages_Chapter_STR " Seiten"))
     )
   ;; *************** Not in novel buffer? Then just count the number of characters ***************
     (message (concat NumberOfChars_STR " Characters, " Pages_STR " Pages"))
   )
)

(defun group-number (num &optional size char)  ;; I stole this somewhere ...
    "Format NUM as string grouped to SIZE with CHAR."
    ;; Based on code for `math-group-float' in calc-ext.el
    (let* ((size (or size 3))
           (char (or char "."))
           (str (if (stringp num)
                    num
                  (number-to-string num)))
           (pt (or (string-match "[^0-9a-zA-Z]" str) (length str))))
      (while (> pt size)
        (setq str (concat (substring str 0 (- pt size))
                          char
                          (substring str (- pt size)))
              pt (- pt size)))
      str))

(defun my/read-file (filename)
  (with-temp-buffer
    (insert-file-contents filename)
    (buffer-substring-no-properties (point-min) (point-max))))

(defun my/Save_Novel_Length ()
;; When loaded the first time save the length of the file under Novel_Status_before.txt
;; also append number of characters to file Novel_Status.txt, with date of the novel’s file
;; After that always compare with current state of novel
  (interactive)
  (defvar Now)
  (defvar File_Date)
  (defvar Save_Status)
  (defvar NumberOfCharacters_STR_without_Point)
  (setq File_Date (concat (format-time-string "%Y-%m-%d" (file-attribute-modification-time (file-attributes "/home/titus/Writer/Org/Novel_Status_before.txt"))) " 00:00:01"))
  (setq Now (concat (format-time-string "%Y-%m-%d") " 00:00:01"))
  ;; if format-time-string is used without variable to format with it, the current time is taken
  (if (> (days-between Now File_Date) 0) ;; file is older than today
    (progn
      (setq NumberOfChars_INT (string-width (buffer-string)))
      (setq Pages_STR (number-to-string (/ NumberOfChars_INT 3000)))
      (setq NumberOfChars_STR (group-number NumberOfChars_INT))
      (setq NumberOfCharacters_STR_without_Point (number-to-string NumberOfChars_INT))
      (setq Percent_INT (/ NumberOfChars_INT (/ OverallGoal 100)))
      (setq Percent_STR (number-to-string Percent_INT))
      (setq Save_Status (concat "Status of work on " (format-time-string "%a, %d.%m.%Y" (visited-file-modtime)) ": " NumberOfChars_STR " characters, " Pages_STR " pages, equals " Percent_STR " Percent.\n"))
      (append-to-file Save_Status nil "/home/titus/Writer/Org/Novel_Status.txt")
      (delete-file "/home/titus/Writer/Org/Novel_Status_before.txt" nil)
      (append-to-file NumberOfCharacters_STR_without_Point nil "/home/titus/Writer/Org/Novel_Status_before.txt"))
  )
)

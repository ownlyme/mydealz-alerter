add-type -assemblyName System.Windows.Forms
add-type -assemblyName System.Drawing

$searchwords = @("*ryzen*","*sn850x*","*galaxy tab*","*amazon*") #not case sensitive

$monitor = 2 #first screen !!!!!!!!!!
$posX = 0
$posY = 780
$flowDirection = "up" # ("up" | "down")
$throttle = 61 #seconds
$sound = "C:\WINDOWS\Media\Windows Notify Calendar.wav"

$searchVendorName = $false
$searchDescription = $false

$boxWidth = 250
$boxHeight = 125

$newDeals = @()
$shownDeals = @()

function goForm
{
	[CmdletBinding()]
	Param(
	[string]$name,
	[int]$id,
	[string]$price,
	[int]$windowX,
	[int]$windowY,
	[string]$link,
	[int]$boxWidth,
	[int]$boxHeight
	)
	[void][reflection.assembly]::LoadWithPartialName("System.Windows.Forms")

	[System.Windows.Forms.Application]::EnableVisualStyles();
	$form = new-object Windows.Forms.Form
	if (Test-Path -Path "$env:temp\mydealz$id.jpg" -PathType Leaf)
	{
		$file = (get-item "$env:temp\mydealz$id.jpg")
		$filename = "$env:temp\foo.png" 
	}
	$Font = New-Object System.Drawing.Font("Arial", 45, [System.Drawing.FontStyle]::Bold)
	
	$img = [System.Drawing.Image]::FromFile($file)
	$targetImgSize = [int]($boxHeight*0.75)
	$scaleX = $targetImgSize/$img.Width
	$scaleY = $targetImgSize/$img.Height
	$scale = [math]::min($scaleX,$scaleY)
	$newX = $img.Width*$scale
	$newY = $img.Height*$scale
	
    $bmp = New-Object System.Drawing.Bitmap($boxWidth, $boxHeight)

	$p0 = New-Object System.Drawing.Point(0, 0)
	$p1 = New-Object System.Drawing.Point([int]($boxWidth*1.125), [int]($boxHeight*0.25))

	$c1 = [System.Drawing.Color]::FromArgb(255, 0, 55, 0)
	$c0 = [System.Drawing.Color]::FromArgb(255, 0, 0, 0)
	$gradientBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush($p0, $p1, $c0, $c1)
	
	$graphics = [System.Drawing.Graphics]::FromImage($bmp)
	$graphics.FillRectangle($gradientBrush, 0, 0, $bmp.Width, $bmp.Height)

	$fontSize = ([int]($boxHeight/15))
	$fontSizePrice = ([int]($boxHeight/8))
	$font = new-object System.Drawing.Font Consolas,$fontSize
	$fontPrice = new-object System.Drawing.Font Consolas,$fontSizePrice
	$brushBg = [System.Drawing.SolidBrush]::New([System.Drawing.Color]::FromArgb(105, 0, 0, 0))
	$brushFg = [System.Drawing.Brushes]::White 
	
	
	$graphics.FillRectangle($brushBg,4,$boxHeight - 4 - $targetImgSize,$newX,$targetImgSize) 
    $graphics.DrawImage($img, 4, ($boxHeight - 4 - $targetImgSize)+[int](($targetImgSize - $newY)/2), $newX, $newY)
	$graphics.FillRectangle($brushBg,0,0,$boxWidth,[int]($boxHeight/3))
	
	$wordWrapAt = 44*(12/$fontSize)*($boxWidth/400)
	
	$tempName = " "+$name
	$lineNumber = 0
	while ($tempName.length -gt $wordWrapAt)
	{
		for ($i = $wordWrapAt; $i -gt 0; $i--)
		{
			if ($tempName[$i] -eq " ")
			{
				break
			}
			
		}
		if ($i -lt ([int]($wordWrapAt/2)))
		{
			$i = $wordWrapAt
		}
		$newLine = $tempName.substring(1,$i)
		$tempName = $tempName.substring($i,$tempName.length-$i)
		$graphics.DrawString($newLine,$font,$brushFg,4,$lineNumber*($fontsize+3)) 
		$lineNumber++
	}
	$graphics.DrawString($tempName.substring(1),$font,$brushFg,4,$lineNumber*($fontsize+3)) 

	$graphics.DrawString($price,$fontPrice,$brushFg,([int]($boxWidth*5/8)),([int]($boxHeight*3/4))) 
	
	$pictureBox = new-object Windows.Forms.PictureBox
	$pictureBox.Image = $bmp
	$pictureBox.Width =  $boxWidth
	$pictureBox.Height =  $boxHeight
	$form.controls.add($pictureBox)
	$form.StartPosition = "manual"
	$form.Location = New-Object System.Drawing.Size($windowX, $windowY)
	$form.width = $boxWidth
	$form.height = $boxHeight
	$form.ControlBox = false
	$form.FormBorderStyle= [System.Windows.Forms.FormBorderStyle]::None
	$form.controls.Add_MouseDown({
		if ($_.Button -eq [System.Windows.Forms.MouseButtons]::Middle ) {
            #[System.Windows.MessageBox]::Show("Rigth mouse up")
			Start $link
        }
		else
		{
			$Form.close()
		}
	})
	$form.Add_Shown( { $form.Activate() } )
	$topmost = New-Object 'System.Windows.Forms.Form' -Property @{TopMost=$true}
	$form.ShowDialog($topmost)
}

$forms = @()
while ($true)
{
	$rss = Invoke-RestMethod -Uri "https://www.mydealz.de/rss/new"
	foreach ($deal in $rss)
	{
		
		#echo $deal.title.InnerText
		#echo $deal.merchant.name.InnerText
		#echo $deal.merchant.price
		$price = $deal.merchant.price
		$vendor = $deal.merchant.name
		$description = $deal.description.InnerText
		$link = $deal.link
		$dealTitle = $deal.title.InnerText.ToString()
		
		if (! ($newDeals -contains $link))
		{
			$newDeals += $link
			echo $dealTitle
			echo $price
			echo $link
			echo $deal.pubDate
			echo " "
			echo " "
		}
		
		$foundMatch = $false
		$searchPlace = $dealTitle
		foreach ($searchword in $searchwords)
		{
			if ($searchPlace -like $searchword)
			{
				$foundMatch = $searchword
				break
			}
		}
		if (!$foundMatch -and $searchVendorName)
		{
			$searchPlace = $vendor
			foreach ($searchword in $searchwords)
			{
				if ($searchPlace -like $searchword)
				{
					$foundMatch = $searchword
					break
				}
			}
		}
		if (!$foundMatch -and $searchDescription)
		{
			$searchPlace = $description
			foreach ($searchword in $searchwords)
			{
				if ($searchPlace -like $searchword)
				{
					$foundMatch = $searchword
					break
				}
			}
		}
		if ($foundMatch -and ($searchPlace -like $foundMatch) -and !($shownDeals -contains $link)) #because i encountered weird false positives
		{
			$shownDeals += $link
			(New-Object Media.SoundPlayer $sound).Play();
			$freeFormId = $forms.length
			for ($i=0;$i -lt $forms.length;$i++)
			{
				$form = $forms[$i]
				if ($form.job.State -ne "Running")
				{
					$freeFormId = $i
					break
				}
			}
			if ($freeFormId -ge $forms.length)
			{
				$forms += 0
			}
			#$dealTitle
			$thumbnail = $deal.content.url
			Remove-Item -Force -ErrorAction Ignore "$env:temp\mydealz$freeFormId.jpg"
			Invoke-WebRequest $thumbnail -OutFile "$env:temp\mydealz$freeFormId.jpg"
			#echo $freeFormId
			$screens = [System.Windows.Forms.Screen]::AllScreens
			$windowX = $screens[$monitor-1].WorkingArea.Location.X+$posX
			$windowY = $posY
			if ($flowDirection -eq "up")
			{
				$windowY = [math]::max(0,$windowY - $freeFormId*($boxHeight+5))
			}
			else
			{
				$windowY = [math]::min($screens[$monitor-1].WorkingArea.Height-180,$windowY + $freeFormId*($boxHeight+5))
			}
			$job = start-job -ArgumentList $dealTitle,$freeFormId,$price,$windowX,$windowY,$link,$boxWidth,$boxHeight $function:goForm
			
			$forms[$freeFormId] = [pscustomobject]@{jobId=$job.Id; title=$dealTitle; job=$job}
		}
		
	}
	Start-Sleep -Seconds $throttle
}

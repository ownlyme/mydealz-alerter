add-type -assemblyName System.Windows.Forms
add-type -assemblyName System.Drawing

$searchwords = @("*playstore*","*saturn*","*jack & jones*") #not case sensitive

$monitor = 2 #first screen         !!!!!!!!!!
$posX = 0
$posY = 500
$flowDirection = "down" # ("up" | "down")
$throttle = 61 #seconds
$sound = "C:\WINDOWS\Media\Windows Notify Calendar.wav"

$checkedDeals = @()

function goForm
{
	[CmdletBinding()]
	Param(
	[string]$name,
	[int]$id,
	[string]$price,
	[int]$windowX,
	[int]$windowY,
	[string]$link
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
	$scaleX = 200/$img.Width
	$scaleY = 160/$img.Height
	$scale = [math]::min($scaleX,$scaleY)
	$newX = $img.Width*$scale
	$newY = $img.Height*$scale
	
    $bmp = New-Object System.Drawing.Bitmap(400, 200)

	$p0 = New-Object System.Drawing.Point(0, 0)
	$p1 = New-Object System.Drawing.Point(450, 40)
	$c1 = [System.Drawing.Color]::FromArgb(255, 0, 55, 0)
	$c0 = [System.Drawing.Color]::FromArgb(255, 0, 0, 0)
	$gradientBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush($p0, $p1, $c0, $c1)
	
	$graphics = [System.Drawing.Graphics]::FromImage($bmp)
	$graphics.FillRectangle($gradientBrush, 0, 0, $bmp.Width, $bmp.Height)

	$font = new-object System.Drawing.Font Consolas,12 
	$fontPrice = new-object System.Drawing.Font Consolas,24
	$brushBg = [System.Drawing.SolidBrush]::New([System.Drawing.Color]::FromArgb(100, 0, 0, 0))
	$brushFg = [System.Drawing.Brushes]::White 

	$graphics.FillRectangle($brushBg,4,36,$newX,160) 
    $graphics.DrawImage($img, 4, 36+[int]((160-$newY)/2), $newX, $newY)
	$graphics.FillRectangle($brushBg,0,0,$bmp.Width,50)
	
	$tempName = $name
	$lineNumber = 0
	while ($tempName.length -gt 42)
	{
		for ($i = 42; $i -gt 0; $i--)
		{
			if ($tempName[$i] -eq " ")
			{
				break
			}
			
		}
		if ($i -lt 19)
		{
			$i = 42
		}
		$newLine = $tempName.substring(0,$i)
		$tempName = $tempName.substring($i,$tempName.length-$i)
		$graphics.DrawString($newLine,$font,$brushFg,10,$lineNumber*14) 
		$lineNumber++
	}
	$graphics.DrawString($tempName,$font,$brushFg,10,$lineNumber*14) 

	$graphics.DrawString($price,$fontPrice,$brushFg,250,150) 
	
	$pictureBox = new-object Windows.Forms.PictureBox
	$pictureBox.Image = $bmp
	$pictureBox.Width =  400
	$pictureBox.Height =  200
	$form.controls.add($pictureBox)
	$form.StartPosition = "manual"
	$form.Location = New-Object System.Drawing.Size($windowX, $windowY)
	$form.width = 400
	$form.height = 200
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
	$form.ShowDialog()
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
		$link = $deal.link
		$dealTitle = $deal.title.InnerText.ToString()
		
		if (! ($checkedDeals -contains $link))
		{
			$checkedDeals += $link
			echo $dealTitle
			echo $price
			echo $link
			echo $deal.pubDate
			echo " "
			
			#echo " "
			$foundMatch = $false
			foreach ($searchword in $searchwords)
			{
				if ($dealTitle -like $searchword)
				{
					$foundMatch = $true
				}
			}
			if ($foundMatch)
			{
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
					$windowY = [math]::max(0,$windowY - $freeFormId*205)
				}
				else
				{
					$windowY = [math]::min($screens[$monitor-1].WorkingArea.Height-180,$windowY + $freeFormId*205)
				}
				$job = start-job -ArgumentList $dealTitle,$freeFormId,$price,$windowX,$windowY,$link $function:goForm
				
				$forms[$freeFormId] = [pscustomobject]@{jobId=$job.Id; title=$dealTitle; job=$job}
			}
		}
	}
	Start-Sleep -Seconds $throttle
}
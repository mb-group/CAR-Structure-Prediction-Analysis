for i in GRP78_1X_Pep_mutIgG4H_CD28TMz_tCd19 CD123CAR.CD28HTM.CD28z GRP78.Gly4Serx3.CD123.CD28HTM.CD28z.tCD19 GRP78.B2M.CD123.CD28HTM.CD28z.tCD19 GRP78.mIgG4.CD123.CD28HTM.CD28z.tCD19 GRP78.GPcPcPc.CD123.CD28HTM.CD28z.tCD19 MGA271.CD8a.CD28z GRP78.G4S3.MGA271.CD8a.CD28z GRP78.Gly4Serx3.MGA271.CD28HTM.CD28z.tCD19 

do
for j in scfv_no_signalpep scfv+tm_no_signalpep
do

cat <<EOF > $i/$j/$i/gnuplot-pae.p
set size 1, 1
set terminal postscript eps solid color enhanced lw 3.0 "Arial" 25
set termoption enhanced
set encoding iso_8859_1
set key left bottom font ",25" maxrows 2
set output "pae.ps"
set macros
POS = "at graph 0.9,0.93 font ',45'"
POL = "at graph 0.1,0.93 font ',45'"
set style circle radius 0.02
set ylabel 'Aligned Residue' font ',40'
set xlabel 'Scored Residue' font ',40'
set palette defined (-1 'dark-green', 1 'white')
set pm3d map

splot 'pae.txt' matrix
#plot 'pae.txt' matrix with image
########################
EOF

cat <<EOF > $i/$j/$i/gnuplot-pae.sh
gnuplot gnuplot-pae.p
ps2epsi pae.ps
epstopdf pae.epsi
#epspdf pae.epsi
rm *ps *psi
open pae.pdf
EOF

cat <<EOF > $i/$j/$i/gnuplot-plddt.prm
set size 1, 1
set terminal postscript eps solid color enhanced lw 3.0 "Arial" 25

set termoption enhanced
set encoding iso_8859_1
set key left bottom font ",25" maxrows 2
set output "plddt.ps"
set macros
POS = "at graph 0.9,0.93 font ',45'"
POL = "at graph 0.1,0.93 font ',45'"
set style circle radius 0.02
set ylabel 'pLDDT Score' font ',40'
set xlabel 'Residue #' font ',40'
########################
set yrange [0:100]

plot "<cat plddt.txt | awk '{print NR, \$1}' | awk '\$2<50{print}'" u 1:2 lc rgb 'orange' pt 7 t 'verylow',\
 "<cat plddt.txt | awk '{print NR, \$1}' | awk '\$2>50 && \$2<70 {print}'" u 1:2 lc rgb 'yellow' pt 7 t 'low',\
 "<cat plddt.txt | awk '{print NR, \$1}' | awk '\$2>70 && \$2<90 {print}'" u 1:2 lc rgb 'cyan' pt 7 t 'confident',\
 "<cat plddt.txt | awk '{print NR, \$1}' | awk '\$2>90{print}'" u 1:2 lc rgb 'dark-blue' pt 7 t 'very high'
########################
EOF

cat <<EOF > $i/$j/$i/gnuplot-plddt.sh
gnuplot gnuplot-plddt.prm
ps2epsi plddt.ps
epstopdf plddt.epsi
#epspdf plddt.epsi
rm *ps *psi
open plddt.pdf
EOF

done
done




for i in GRP78_1X_Pep_mutIgG4H_CD28TMz_tCd19 CD123CAR.CD28HTM.CD28z GRP78.Gly4Serx3.CD123.CD28HTM.CD28z.tCD19 GRP78.B2M.CD123.CD28HTM.CD28z.tCD19 GRP78.mIgG4.CD123.CD28HTM.CD28z.tCD19 GRP78.GPcPcPc.CD123.CD28HTM.CD28z.tCD19 MGA271.CD8a.CD28z GRP78.G4S3.MGA271.CD8a.CD28z GRP78.Gly4Serx3.MGA271.CD28HTM.CD28z.tCD19 
do
for j in scfv_no_signalpep scfv+tm_no_signalpep
do

cd $i/$j/$i/
python data_extraction.py
wait
bash gnuplot-pae.sh
wait
bash gnuplot-plddt.sh

cd ../../../
done
done


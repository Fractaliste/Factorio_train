# Refueling
This mods auto skip station named "Plein" (it's configurable le since 0.16.3) if it does not need refueling, and auto redirect to "Plein" station when refueling is needed.

Since 0.16.3 you don't need anymore to manually initiate to your train a station schedule to "Plein" station, it is automatically added (and removed) when needed.

# Autoschedule

Un pattern X#[io]Y est à appliquer aux stations qu'on veut gérer, Y et X état n'importe quelle chaîne alphanumérique. Le caractère "o" comme "output" identifie les stations qui remplissent les wagons, et le caractère "i" comme "input" identifie les stations vidant les wagons.
Le X importe peu et est à la disposition libre de l'utilisateur, le Y en revanche est utilisé par l'autoscheduleur, et les trains seront feront donc des aller-retours entre les stations "o" et "i" ayant le même "Y".

## Algo
Toutes les stations d'inputs sont dans une Fifo.
Toutes les stations d'input et d'output sont indexées par "Y" :
<pre>
-- fifo
-- index
    -- Y1
        -- i
            -- X1#iY1
            -- X2#iY1
            -- ...
        -- o
            -- X3#oY1
            -- X4#oY1
            -- ...
</pre>
Toutes les X tick on itère sur les idles trains afin de leur assigner une mission. Pour ce faire pour chaque train on fait :
<pre>
Prendre le haut de la pile des stations d'input
    SI NOT premier passage
        Comparer la station courante avec la référence et STOP si c'est la même (on a fait un tour)
    SINON
        Noter la référence
    
    SI la station est invalide
        On passe immédiatement à la station suivante
    SINON SI la station est actuellement désservie OU qu'il n'y a pas de station d'output correspondant ET valide
        On la remet en bas de la pile et on passe à la station suivante
    SINON
        On attribut au train le trajet Output -> Input -> Parkin
        STOP
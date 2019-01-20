# Refueling
This mods auto skip station named "Plein" (it's configurable le since 0.16.3) if it does not need refueling, and auto redirect to "Plein" station when refueling is needed.

Since 0.16.3 you don't need anymore to manually initiate to your train a station schedule to "Plein" station, it is automatically added (and removed) when needed.

# Autoschedule

Un pattern X#[io]Y est à appliquer aux stations qu'on veut gérer, Y et X état n'importe quelle chaîne alphanumérique. Le caractère "o" comme "output" identifie les stations qui remplissent les wagons, et le caractère "i" comme "input" identifie les stations vidant les wagons.
Le X importe peu et est à la disposition libre de l'utilisateur, le Y en revanche est utilisé par l'autoscheuleur, et les trains seront feront donc des aller-retours entre les stations "o" et "i" aynt le même "Y".

## Algo
Toutes les stations d'inputs sont dans une Fifo